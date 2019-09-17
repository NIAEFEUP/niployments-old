#!/usr/bin/env bash

contains() {
    # $1 haystack/list (bash list aka string with spaces)
    # $2 needle/item
    # Returns 0 if there's a match or 1 otherwise
    [[ "$1" =~ (^|[[:space:]])"$2"($|[[:space:]]) ]]
}

has_docker() {
    [[ $(command -v docker) ]] && docker --version | grep -q 'Docker version'
}

export -f contains has_docker
