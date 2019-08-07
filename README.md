# niployments

Repository to manage and document NIAEFEUP's deployments.

## Reasoning

> "It's 2019 and we are still manually `ssh`'ing into a machine instead of using fancy stuff that will also inevitably break!"

The objective is to have a place for not only backing up, but also generally version controlling server configs.
This will make them more accessible (scary, but probably good) and let's not forget that [bugs are shallow](https://en.wikipedia.org/wiki/Linus%27s_Law).

## Contents

This repo will contain the configurations of the branch's _production_ web server, some configs for CD by tracking the `master` branch of some repos (either via `cron` or webhooks, under discussion) and other notes that might be relevant.

## Continuous Deployment

CD will be setup. In order to be eligible to do so, a project must include a `deploy.sh` script and get in touch with the current maintainer of this project (in case of doubt, yell in Slack).
This project must also have a path (and port, if necessary) allocated to it (will be documented here, hopefully).

## Secret Management

Obviously, especially since this not a private repo (and even if it were!) secrets are not to be used here. Instead investigate solutions like using environment variables or relying on local configuration files (such as `.env`s, for example).
