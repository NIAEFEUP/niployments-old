#!/usr/bin/env bash

# Helper functions for interacting with Slack's API

# See https://sipb.mit.edu/doc/safe-shell/
set -ueo pipefail

# Adaptation of https://stackoverflow.com/questions/192292/how-best-to-include-other-scripts
# Necessary because of reading the token below
curr_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$curr_dir" ]]; then curr_dir="${0%/*}"; fi

function send_text_file_message() {
    local message="$1" file="$2"

    # stderr to stdout and then using jq to pretty-print it
    exec 2>&1
    curl --silent \
    -F file=@"$file" \
    -F "initial_comment=$message" \
    -F 'filetype=text' \
    -F channels='#github' \
    -H "Authorization: Bearer $(cat "$curr_dir/niployments-bot.slack.token")" \
    https://slack.com/api/files.upload \
    | jq .
}

export -f send_text_file_message
