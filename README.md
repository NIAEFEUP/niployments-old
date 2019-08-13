# niployments
[![CircleCI](https://circleci.com/gh/NIAEFEUP/niployments/tree/master.svg?style=svg)](https://circleci.com/gh/NIAEFEUP/niployments/tree/master)

Repository to manage and document NIAEFEUP's deployments.

## Reasoning

> "It's 2019 and we are still manually `ssh`'ing into a machine instead of using fancy stuff that will also inevitably break!"

The objective is to have a place for not only backing up, but also generally version controlling server configs.
This will make them more accessible (scary, but probably good) and let's not forget that [bugs are shallow](https://en.wikipedia.org/wiki/Linus%27s_Law).

## Contents

- `server-configs` - Configurations of niserver (such as apache configs, for example)
- `utils` - Random (bash) utils
- `deployments` - Configuration for deployment of ni projects
- `slack` - Utilities for communicating with Slack

This repo will contain the configurations of the branch's _production_ web server (niserver), some configs for CD by tracking the `master` branch of some repos (either via `cron` or webhooks, under discussion) and other notes that might be relevant.

## Continuous Deployment

CD will be setup. In order to be eligible to do so, a project must follow certain criteria:
- Have branch protection rules in place for at least the `master` branch (really don't want to handle broken deploys :( )
- Include a `Dockerfile-prod` that when built and ran will expose a running server to a certain port (`.env` or always 80 and remapped?)
- Finally, get in touch with the current maintainer of this project (should be the deployers github team - but in case of doubt, yell in Slack).

This project must also have a path (and port, if necessary) allocated to it (which will be documented in `server-configs`, hopefully).

For further details, take a look at `deployments/`.


## Secret Management

Obviously, especially since this not a private repo (and even if it were!) secrets are not to be used here. Instead investigate solutions like using environment variables or relying on local configuration files (such as `.env`s, for example).
