#!/usr/bin/env bash

# Deployment script for ni's projects
# Run with deploy.sh <project-id>
# In which project-id is the project's github identifier (that identifies the repo and subsequently the folder under which it is)

# See https://sipb.mit.edu/doc/safe-shell/
set -ueo pipefail

# Adaptation of https://stackoverflow.com/questions/192292/how-best-to-include-other-scripts
curr_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$curr_dir" ]]; then curr_dir="${0%/*}"; fi

project="${1:-}"
branch="${2:-master}"

# shellcheck source=utils/utils.sh
source "$curr_dir/../utils/utils.sh"

# List of git id name thing of the projects configured for autodeploy
configured_projects="NIAEFEUP-Website tts-fe nijobs-fe nijobs-be"

if [[ -z "$project" ]] || ! contains "$configured_projects" "$project"; then
    >&2 echo "Project to deploy not specified or not configured (Received: $project)"
    exit 1
fi

if ! has_docker; then
    >&2 echo "Docker is not installed!"
    >&2 echo "Please install Docker to use this!"
    exit 2
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
    exit 3
fi

# Ensuring up to date with remote (correct branch and latest commit, discarding all local changes)
git checkout --force --quiet "$branch"
git reset --hard --quiet "origin/$branch"

logfile="$(mktemp --tmpdir niployments-log.XXXXXX.txt)"
rev="$(git rev-parse --short "origin/$branch")"
branch_at_rev="$branch@$rev"

set +e
(
    echo "###-> Deploying $project at $branch_at_rev"
    echo

    deploy_default "$project" "$branch"
) 2>&1 | tee "$logfile"

# This gets the return status of the first element of the previous pipe, aka the subshell executing the deployment commands
deploy_status="${PIPESTATUS[0]}"
set -e
# Exiting the project, back to the original folder (probably deployments but might be another one, irrelevant)
popd > /dev/null

echo "Deployment exit status: $deploy_status"

# Building slack message
if [[ "$deploy_status" == "0" ]]; then
    message=":ship: Deployed *$project* at "'`'"$branch_at_rev"'`'
else
    message=":exploding_head: Failed to deploy *$project* at "'`'"$branch_at_rev"'`'", return code: $deploy_status"
fi

## Send slack message
echo "Sending slack message with deployments information"
slack_response="$(send_file_message "$message" "$logfile")"

echo "Slack Response:"
echo "$slack_response"

rm -rf "$logfile"

exit "$deploy_status"
