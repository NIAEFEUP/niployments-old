# Auto-deployment of NIAEFEUP's projects

This aims to configure simplified deployment of ni's projects via running of some simple bash scripts.

## Configuring a new project for deployment

Besides ensuring the project complies with the rules specified in the root README, the deployers of ni (github team hopefully, for access control) should `ssh` into `niserver` and perform the following steps:

1. `git clone` the repository into this directory
1. Configure the necessary dependencies and `.env*` variables for the project's correct deployments
1. Update the configs in `./project-configs.sh` (allocated port and location of .env file - optional but recommended, see below for details)
1. Update the configs found in `../server-configs` if necessary (such as apache routes or port mappings, for example)

The rest should be handled by the scripts' modularity (hopefully).

### Project-specific configurations

Each project's _`.env` file_ and _exposed port_ must be documented in `project-configs.sh`. This file is sourced by `deploy.sh` in order to use the necessary project-specific configs.

The `port` is mandatory, but the `env_file_path` and `docker_flags` are optional (for projects that might not make use of those).

The paths provided in the said file **MUST** be **absolute** (trust me you don't want to handle bash's path spaghetti :upside_down_face: :wink:).

## Notes

`docker system prune` should be run periodically to clean up dangling images and containers. The deployment scripts attempt to minimize the number of these but some are left on purpose due to speeding up multi-stage builds.

The containers cannot connect to `localhost` - to enable that they would have to be running in host network mode, which would complicate port mapping in things like nginx containers, which do not provide this easily.  
In order to connect to other docker containers, use `docker network` and manage the networks using that. This will probably break in each deployment, as the container will change, but it is the best solution I can come up with for now. In the future, this should be improved though, obviously.

The standard location for docker volumes is `deployments/volumes-data`. It should be properly linked in the project's `docker_flags`.