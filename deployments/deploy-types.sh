#!/usr/bin/env bash

### Deployment definitions based on project type
### To be used by deploy.sh

# See https://sipb.mit.edu/doc/safe-shell/
set -ueo pipefail

# For projects that only need their assets to be built and can then be served by an apache server
# (for example, and what is currently configured so let's roll with it instead of using docker images with nginx inside of them too... spaghet)
function deploy_static_build() {
    local project="$1" branch="$2" image_tag="$project:$branch"

    docker build -f Dockerfile-prod -t "$image_tag" .

    # Early returns using the status of build and of run to prevent removal of potentially relevant things
    local build_status="$?"
    if [ "$build_status" != 0 ]; then
	return "$build_status"
    fi

    mkdir -p build
    # Using --cidfile to store the pid of the running container
    docker run --cidfile build.cid 
    local run_status="$?"
    if [ "$run_status" != 0 ]; then
	return "$run_status"
    fi

    # Assuming the Dockerfile-prod specified above uses WORKDIR /web/
    docker cp "$(cat build.cid):/web/build/" .
    # The built files are now available in ./build/ - ready to be served via a webserver like apache or nginx or any other similar solution

    # Cleanup
    # Removes the running container
    docker rm -f "$(cat build.cid)"
    rm -f build.cid
    # Removes the image used to run the container
    docker rmi -f "$image_tag"
}

# For projects that need to be running a daemon of some sort (such as back-ends and server-side rendering)
function deploy_running() {
    local project="$1" branch="$2" image_tag="$project:$branch"

    docker build -f Dockerfile-prod -t "$image_tag" .

    # Early returns using the status of build and of run to prevent removal of potentially relevant things
    local build_status="$?"
    if [ "$build_status" != 0 ]; then
	return "$build_status"
    fi

    # Remove previously running container
    # TODO

    # Run app as daemon that will remove its own container on exit
    docker run -d --rm "$image_tag"

}

export -f deploy_static_build deploy_running
