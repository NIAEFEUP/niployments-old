# niployments
[![CircleCI](https://circleci.com/gh/NIAEFEUP/niployments/tree/master.svg?style=svg)](https://circleci.com/gh/NIAEFEUP/niployments/tree/master)

Repository to manage and document NIAEFEUP's deployments.

## Reasoning

> "It's 2019 and we are still manually `ssh`'ing into a machine instead of using fancy stuff that will also inevitably break!"

The objective is to have a place for not only backing up, but also generally version controlling server configs.
This will make them more accessible (scary, but probably good) - let's not forget that [bugs are shallow](https://en.wikipedia.org/wiki/Linus%27s_Law).

## Contents

- `server-configs` - Configurations of niserver (such as apache configs, for example)
- `utils` - Random (bash) utils
- `deployments` - Configuration for deployment of ni projects
- `dockerfile-templates` - Templates of production-ready Dockerfiles, to use in projects to then be used by `deployments`
- `slack` - Utilities for communicating with Slack

This repo will contain the configurations of the branch's _production_ web server (niserver), some configs for CD by tracking the `master` branch of some repos (via `cron` - webhooks would be more trouble than it's worth) and other notes that might be relevant.

## Continuous Deployment

CD will be setup. In order to be eligible to do so, a project must follow certain criteria:

- Have branch protection rules in place for at least the `master` branch (really don't want to handle broken deploys :( )
- Provide a `Dockerfile-prod` that when built and ran exposes a running server to port 80 (which is then remapped in the `docker run` command) - there are some examples available in `dockerfile-templates/`
    * A `PORT` env variable with the value of `80` will also be passed when running, so you can also rely on that if you ensure that that works.
    * Simillarly, it is also possible to rely on `.env*` configuration files (mapped in `deployments/project-configs.sh`)
- Finally, get in touch with the current maintainer of this project (should be the deployers github team - but in case of doubt, yell in Slack).

**Note:** Currently all of the projects must be running a daemon exposing a port. Static builds should use something like nginx to expose the built files. (See `dockerfile-templates/Dockerfile-react` as an example of this)

The project to deploy must also have a path (URI) and port allocated to it (which will be documented in `server-configs`, hopefully - or at least in `deployments/project-configs` (PORT) and in `server-configs/apache/config-modules/routing.conf` (URI)). Again, in case of doubt: bother people.

For further details, take a look at `deployments/`.


## Secret Management

Obviously, especially since this not a private repo (and even if it were!) secrets are not to be used here. Instead use other options such as environment variables or relying on local configuration files (such as `.env`s, for example).
