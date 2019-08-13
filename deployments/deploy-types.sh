#!/usr/bin/env bash

### Deployment definitions based on project type
### To be used by deploy.sh

# See https://sipb.mit.edu/doc/safe-shell/
set -ueo pipefail

# For deploying stuff with docker, simply put.
function deploy_default() {
    local project="$1" branch="$2" image_tag="$project---$branch"

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
    if [ "$build_status" != 0 ]; then
	>&2 echo -e "\n###-> ERROR! Build failed! Aborting deployment!"
	return "$build_status"
    fi

    # Stopping old docker container and waiting for it to exit
    echo -e "\n###-> Build done. Stopping old container and waiting for it to exit\n"
    docker stop "$old_container_id"
    docker wait "$old_container_id"
    
    echo -e "\n###-> Old container stopped, running new one\n"
    docker run -d --restart=unless-stopped "$image_tag"
    local run_status="$?"
    if [ "$run_status" != 0 ]; then
	>&2 echo -e "\n###-> ERROR! Run failed!"
	>&2 echo "###-> Retagging old image and starting old container back up"
	docker tag "$old_image_id" "$image_tag"
	docker start "$old_container_id"
	return "$run_status"
    fi

    # Cleanup
    echo -e "\n###-> New container now running successfuly, removing old container and image!"
    docker rm "$old_container_id"
    docker rmi "$old_image_id"
    
    return "$run_status"
}

export -f deploy_default

