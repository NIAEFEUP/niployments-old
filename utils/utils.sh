#!/usr/bin/env bash

contains() {
    # $1 haystack/list (bash list aka string with spaces)
    # $2 needle/item
    # Returns 0 if there's a match or 1 otherwise
    [[ "$1" =~ (^|[[:space:]])"$2"($|[[:space:]]) ]]
}

export -f contains
