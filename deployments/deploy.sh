#!/usr/bin/env bash

# Deployment script for ni's projects
# Run with deploy.sh [--cron-mode] <project-id>
# In which project-id is the project's github identifier (that identifies the repo and subsequently the folder under which it is)

# See https://sipb.mit.edu/doc/safe-shell/
set -ueo pipefail

# Checking for the script being run via cron. If so then we will not redeploy when the branch is up to date
if [[ "$1" == "--cron-mode" ]]; then
    CRON_MODE=1
    echo "Deploy script running in cron mode. Will abort deployment if branch is up to date."
    shift
fi

# Adaptation of https://stackoverflow.com/questions/192292/how-best-to-include-other-scripts
curr_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$curr_dir" ]]; then curr_dir="${0%/*}"; fi

project="${1:?Project to deploy argument is mandatory and was not given\!}"
branch="${2:-master}"

# shellcheck source=utils/utils.sh
source "$curr_dir/../utils/utils.sh"

# Getting project configurations (configured_projects, project_port and project_dotenv_location)
# shellcheck source=deployments/project-configs.sh
source "$curr_dir/project-configs.sh"

if ! contains "$configured_projects" "$project"; then
    >&2 echo "Project given to deploy not configured (Received: $project)"
    exit 1
fi

if ! has_docker; then
    >&2 echo "Docker is not installed!"
    >&2 echo "Please install Docker to use this!"
    exit 2
fi

# Ensuring that deploys of the same project do not trample each other
# See https://mywiki.wooledge.org/BashFAQ/045
exec 9>"/tmp/niployments-$project-deploy.lock"
if ! flock -n 9; then
    echo "Another instance of the deployment scripts is already running for $project"
    echo "Exiting in order to not trample myself!"
    exit 3
fi

## Sourcing files here because otherwise the directory will change and will no longer work
# Getting deployment types definitions
# shellcheck source=deployments/deploy-types.sh
source "$curr_dir/deploy-types.sh"
# Get slack messaging functions
# shellcheck source=slack/messaging.sh
source "$curr_dir/../slack/messaging.sh"

pushd "$project" > /dev/null
if ! MSG="$(git fetch origin 2>&1)"; then
    >&2 echo "-> Problem in git fetch on $project"
    >&2 echo "$MSG"
    exit 4
fi

# Ensuring up to date with remote (correct branch and latest commit, discarding all local changes)
git checkout --force --quiet "$branch"
# However, check for branch already being up to date when in cron mode, in order to abort if so
if [[ -n "${CRON_MODE:-}" ]]; then
    # From https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git
    UPSTREAM='@{u}'
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")

    if [ "$LOCAL" = "$REMOTE" ]; then
        # Up-to-date
        echo "Local already up to date, not deploying."
        exit 5
    elif [ "$LOCAL" = "$BASE" ]; then
        # Need to pull
        echo "Local is behind remote, continuing with deployment"
    elif [ "$REMOTE" = "$BASE" ]; then
        # Need to push
        echo "Local is ahead of remote, git spaghetti! Warning in slack and bailing!"

        # Exiting the project, back to the original folder (probably deployments but might be another one, irrelevant)
        # This is done so that the slack messages file (exporting slack messaging functions) has the correct path to its token file
        popd > /dev/null

        project_in_branch='`'"$project"'`'" in "'`'"$branch"'`'
        ahead_message=":rotating_light: Niployments local for $project_in_branch is ahead of its tracked remote! Please run "'`'"git unspaghet"'` :spaghetti:! :rotating_light:'
        slack_ahead_response="$(send_text_message "$ahead_message")"
        echo "Slack Response:"
        echo "$slack_ahead_response"
        exit 6
    else
        # Diverged
        # TODO: Discuss what to do here better, for now just ignoring it as a force-push or something of the sort
        echo "Local diverged from master. Considering it a force-push or similar and continuing with the deployment."
    fi
fi
git reset --hard --quiet "origin/$branch"

logfile="$(mktemp --tmpdir niployments-log.XXXXXX.txt)"
rev="$(git rev-parse --short "origin/$branch")"

set +e
(
    echo "###-> Deploying $project at $branch@$rev"
    echo
    
    # Passing in the configs from ./project-configs.sh. dotenv_location might not be set so sending instead an empty variable ("") so that the 'unbound variable' error does not occur
    deploy_default "$project" "$branch" "${project_port[$project---$branch]}" "${project_dotenv_location[$project---$branch]:-}"
) 2>&1 | tee "$logfile"

# This gets the return status of the first element of the previous pipe, aka the subshell executing the deployment commands
deploy_status="${PIPESTATUS[0]}"
set -e
# Exiting the project, back to the original folder (probably deployments but might be another one, irrelevant)
popd > /dev/null

echo "Deployment exit status: $deploy_status"

# Building slack message
project_branch_rev_info="*$project* from "'`'"$branch"'`'" at "'`'"$rev"'`'

if [[ "$deploy_status" == "0" ]]; then
    message=":rowboat: Deployed $project_branch_rev_info"
else
    message=":exploding_head: Failed to deploy $project_branch_rev_info, return code: $deploy_status"
fi

## Send slack message
echo "Sending slack message with deployments information"
slack_response="$(send_file_message "$message" "$logfile")"

echo "Slack Response:"
echo "$slack_response"

rm -f "$logfile"

exit "$deploy_status"
