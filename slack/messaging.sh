#!/usr/bin/env bash

# Helper functions for interacting with Slack's API

# See https://sipb.mit.edu/doc/safe-shell/
set -ueo pipefail

# Adaptation of https://stackoverflow.com/questions/192292/how-best-to-include-other-scripts
# Necessary because of reading the token below
curr_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$curr_dir" ]]; then curr_dir="${0%/*}"; fi

NIPLOYMENTS_CHANNEL='#niployments'

# Should work with any files up to 1MB, as per slack API: https://api.slack.com/methods/files.upload
function send_file_message() {
    # filepath should be absolute to ensure there are no problems in reading it
    local message="$1" file_path="$2"

    # stderr to stdout and then using jq to pretty-print it
    # The filename is calculated by removing the leading directories from file_path
    # Using content instead of passing the file so that there is a preview
    exec 2>&1
    curl --silent \
    -F "filename=${file_path##*/}" \
    -F "content=$(cat "$file_path")" \
    -F "initial_comment=$message" \
    -F channels="$NIPLOYMENTS_CHANNEL" \
    -H "Authorization: Bearer $(cat "$curr_dir/niployments-bot.slack.token")" \
    https://slack.com/api/files.upload \
    | jq .
}

export -f send_file_message
