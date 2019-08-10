#!/usr/bin/env bash

# $1 - Identifier of project to deploy (git id name thingy)

# shellcheck source=utils/utils.sh
source ../utils.sh

# List of git id name thing of the projects configured for autodeploy via niployments-bot
configured_projects="NIAEFEUP-Website tts-fe nijobs-fe nijobs-be"

if [[ -z "$1" ]] || ! contains "$configured_projects" "$1"; then
    echo "Project to deploy not specified or not configured (Received: $1)"
    exit 1
fi

echo "Deploying $1"
