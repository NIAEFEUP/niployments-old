# Auto-deployment of NIAEFEUP's projects

This aims to configure simplified deployment of ni's projects via running of some simple bash scripts.

## Configuring a new project for deployment

Besides ensuring the project complies with the rules specified in the root README, the deployers of ni (github team hopefully, for access control) should `ssh` into `niserver` and perform the following steps:

1. `git clone` the repository into this directory
1. Update the the list of configured projects (check deploy.sh for usages)
1. Configure the necessary dependencies and `.env*` variables for the project's correct deployments
1. Update the configs found in `../server-configs` if necessary (such as apache routes or port mappings, for example)

The rest should be handled by the scripts' modularity (hopefully).

### Project-specific configurations

Each project's _`.env` file_ and _exposed port_ must be documented in `project-configs.sh`. This file is sourced by `deploy.sh` in order to use the necessary project specific configs.

The `port` is mandatory, but the `env_file_path` is optional (for projects that might not make use of one).

The paths provided in said file **MUST** be **absolute** (trust me you don't want to handle bash's path spaghetti :wink:).

## Notes

`docker system prune` should be ran periodically to clean up dangling images and containers. The deployment scripts attempt to minimize the number of these but some are left on purpose due to speeding up multi-stage builds.
