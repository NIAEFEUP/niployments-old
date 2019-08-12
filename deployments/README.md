# Auto-deployment of NIAEFEUP's projects

This aims to configure simplified deployment of ni's projects via running of some simple bash scripts.

## Configuring a new project for deployment

Besides ensuring the project complies with the rules specified in the root README, the deployers of ni (github team hopefully, for access control) should `ssh` into `niserver` and perform the following steps:

1. `git clone` the repository into this directory
1. Update the the list of configured projects 
1. Configure the necessary dependencies and `.env` variables for the project's correct deployments
1. Update the configs found in `../server-configs` if necessary (such as apache routes, for example)

The rest should be handled by the scripts' modularity hopefully.
