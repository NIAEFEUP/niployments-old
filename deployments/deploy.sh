#!/usr/bin/env bash

# Deployment script for ni's projects
# Run with deploy.sh <project-id>
# In which project-id is the project's github identifier (that identifies the repo and subsequently the folder under which it is)

# See https://sipb.mit.edu/doc/safe-shell/
set -ueo pipefail

project="${1:-}"
branch="master"

# shellcheck source=utils/utils.sh
source ../utils/utils.sh

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

cd "$project"
if ! MSG="$(git fetch origin 2>&1)"; then
    >&2 echo "-> Problem in git fetch on $project"
    >&2 echo "$MSG"
    exit 3
fi

# Ensuring up to date with remote (correct branch and latest commit, discarding all local changes)
git checkout --force --quite "$branch"
git reset --hard --quiet "origin/$branch"

logfile="$(mktemp deploylog.XXXXXX.txt)"
rev="$(git rev-parse --short "origin/$branch")"
branch_at_rev="$branch@$rev"

# Getting deployment types definitions
# shellcheck source=deployments/deploy-types.sh
source ./deploy-types.sh

set +e
(
    echo "###-> Deploying $project at $branch_at_rev"
    echo

    # IMPORTANT: Make sure to update this with the added projects' type and add other deploy-type-functions if necessary (in deploy-types/)!
    if [ "$project" = "tts-fe" ] || [ "$project" = "nijobs-fe" ]; then
	deploy_static_build "$project" "$branch"
    else
	deploy_running "$project" "$branch"
    fi
) 2>&1 | tee "$logfile"
set -e

deploy_status="$?"

# Building slack message
if [[ "$deploy_status" == "0" ]]; then
    message=":ship: Deployed *$project* at "'`'"$branch_at_rev"'`'
else
    message=":exploding_head: Failed to deploy *$project* at "'`'"$branch_at_rev"'`'", return code: $deploy_status"
fi

## Send slack message

# Get slack messaging functions
# shellcheck source=slack/messaging.sh
source ../slack/messaging.sh

slack_response="$(send_text_file_message "$message" "$logfile")"

echo "Slack Response:"
echo "$slack_response"

rm -rf "$logfile"

exit $deploy_status
