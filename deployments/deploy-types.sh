#!/usr/bin/env bash

### Deployment definitions based on project type
### To be used by deploy.sh

# See https://sipb.mit.edu/doc/safe-shell/
set -ueo pipefail

function to_lower_case() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# For deploying stuff with docker, simply put.
function deploy_default() {
    # (dotenv_location is not mandatory)
    local project="$1" branch="$2" image_tag port="$3" dotenv_location="${4:-}" docker_volume="${5:-}"
    image_tag="$(to_lower_case "$project---$branch" )"

    # If we have a dotenv file specified, copy it into the current directory (in case of error, `cp` prints something so no need to echo anything)
    [[ -n "$dotenv_location" ]] && cp "$dotenv_location" . && echo "#-> Copied dotenv file successfully"

    # Grabbing the image id from the previous build
    # In case of run failure, we will retag the old image and in case of run success, remove it using `docker rmi`
    local old_image_id
    old_image_id="$(docker images -q "$image_tag")"
    # Grabbing the container id that is currently running an image with the project+branch tag
    local old_container_id
    old_container_id="$(docker ps -aq --filter ancestor="$image_tag")"

    echo -e "Starting docker build\n"
    docker build -f Dockerfile-prod -t "$image_tag" .
    local build_status="$?"

    # Disabled as this meant that no dependencies could be cached. Instead run `docker system prune` periodically to clear up disk space if necessary.
    # echo "Removing intermediate **images** left by docker build (when using multistage dockerfiles)"
    # docker image prune -f --filter label=stage=builder

    if [ "$build_status" != 0 ]; then
	    >&2 echo -e "\n###-> ERROR! Build failed! Aborting deployment!"
	    return "$build_status"
    fi

    # Stopping old docker container and waiting for it to exit
    echo -e "\n###-> Build done. Stopping old container and waiting for it to exit\n"
    if [[ -n "$old_container_id" ]]; then
        docker stop "$old_container_id" &>/dev/null
    	printf "old container exit code: "
    	docker wait "$old_container_id"
    	echo -e "\n###-> Old container stopped.\n"
    else
	    echo "###-> No container was previously running! Continuing..."
    fi    

    # Deploying project Docker container
    echo -e "###-> Running new container\n#-> Will listen on port $port!\n"
    if [[ -n "$docker_volume" ]]; then
        echo -e "\n###-> Linking docker volume: $docker_volume\n"
        docker run -v "$docker_volume" -d --restart=unless-stopped --env PORT=80 -p "$port:80" "$image_tag"
    else
        echo -e "\n###-> No docker volume specified.\n"
        docker run -d --restart=unless-stopped --env PORT=80 -p "$port:80" "$image_tag"
    fi
    local run_status="$?"
    if [ "$run_status" != 0 ]; then
        >&2 echo -e "\n###-> ERROR! Run failed!"
        >&2 echo "###-> Retagging old image and starting old container back up"
        if [[ -n "$old_image_id" ]]; then
            docker tag "$old_image_id" "$image_tag"
        else
            echo "###->> No old image found for retagging!!"
        fi
        if [[ -n "$old_container_id" ]]; then
            docker start "$old_container_id"
        else
            echo "###->> No old container found for starting back up!!"
        fi
        return "$run_status"
    fi

    # Cleanup
    echo -e "\n###-> New container now running successfuly, removing old container and image!"
    if [[ -n "$old_container_id" ]]; then
    	printf "old container id: "
    	docker rm "$old_container_id"
    else
	    echo "###-> No old container was running, so none removed."
    fi

    if [[ -n "$old_image_id" ]]; then
	    if [[ "$(docker images -q "$image_tag")" == "$old_image_id" ]]; then
	        echo "###-> Not removing image, as the container was run using the same one (build did a full cache hit)"
	    else
	        printf "old image id: "
           docker rmi "$old_image_id"
	    fi
    else
	    echo "###-> No old image found, so none removed."
    fi

    return "$run_status"
}

export -f deploy_default
