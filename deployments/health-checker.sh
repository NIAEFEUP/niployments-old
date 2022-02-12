#!/usr/bin/env bash

### Check for service availability after container startup
### To be used by deploy-types.sh

# See https://sipb.mit.edu/doc/safe-shell/
set -ueo pipefail

# Calls a given url and returns 0 if the response status is HTTP 200, 1 otherwise
# Arguments: url - URL to call
function is_healthy_url() {
    local url="$1"

    local response_code
    response_code="$(curl -s -o /dev/null -w "%{http_code}" "$url")"

    if [ "$response_code" == "200" ]; then
        echo 0
    else
        echo 1
    fi

    return 0
}

# Periodically calls a given url until it returns HTTP 200, or max retries is reached. 
# Returns 0 if health check was successful, 1 otherwise
# Arguments: url - URL to call
function health_checker() {
    local url="$1"

    # According to 1 retry every 10 seconds, this will try for 5 minutes
    local MAX_ATTEMPTS=26
    local RETRY_INTERVAL_SECONDS=1

    local is_healthy_result=1
    local retry_count=0

    while [ "$is_healthy_result" -ne 0 ]
    do
        
        if [ "$retry_count" -eq "$MAX_ATTEMPTS" ]; then
            break
        fi
 
        echo -e "[Health Checker] Attempt $retry_count\n"

        is_healthy_result="$(is_healthy_url "$url")"

        if [ "$is_healthy_result" -eq 0 ]; then
            echo -e "[Health Checker] Health Check successfull!\n"
            break
        fi

        echo -e "[Health Checker] Attempt ${retry_count} failed.\n"
        retry_count=$((retry_count+1))
        
        sleep $RETRY_INTERVAL_SECONDS
    done

    if [ "$is_healthy_result" -ne 0 ]; then
        echo -e "[Health Checker] Max number of retries reached. Health Check failed.\n"
    fi

    return "$is_healthy_result"
}

export -f health_checker
