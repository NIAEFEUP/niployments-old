#!/usr/bin/env bash

# List of git id name thing of the projects configured for autodeploy
configured_projects="tts-fe nijobs-fe nijobs-be"

# Configuration of each project's port and env file location
# Uses bash dictionaries: https://devhints.io/bash#dictionaries

# The dictionary keys must be in the format "${project_github_id}---${branch}" (see examples below)
# The dotenv location is not mandatory, but if given it must exist.

declare -A project_port
declare -A project_dotenv_location
declare -A project_docker_flags

# tts
project_port[tts-fe---master]=3100
project_dotenv_location[tts-fe---master]='/home/ubuntu/niployments/deployments/env-files/nijobs-be/master/.env'

# (Thanks to this modular config, it is possible to also deploy staging (painlessly!))
# nijobs-fe
project_port[nijobs-fe---master]=4001
project_dotenv_location[nijobs-fe---master]='/home/ubuntu/niployments/deployments/env-files/nijobs-fe/master/.env'

## nijobs-fe staging
project_port[nijobs-fe---develop]=4002
project_dotenv_location[nijobs-fe---develop]='/home/ubuntu/deployments/env-files/nijobs-fe/develop/.env'

# nijobs-be
project_port[nijobs-be---master]=4010
project_dotenv_location[nijobs-be---master]='/home/ubuntu/niployments/deployments/env-files/nijobs-be/master/.env.local'
project_docker_flags[nijobs-be---master]='-v /home/ubuntu/niployments/deployments/volumes-data/nijobs:/usr/src/app/static'

## nijobs-be staging
project_port[nijobs-be---develop]=4011
project_dotenv_location[nijobs-be---develop]='/home/ubuntu/niployments/deployments/env-files/nijobs-be/develop/.env.local'
project_docker_flags[nijobs-be---develop]='-v /home/ubuntu/niployments/deployments/volumes-data/nijobs-beta:/usr/src/app/static'

# debug example:
# project_dotenv_location[nijobs-be---develop]='/home/miguel/Coding/NIAEFEUP/niployments/deployments/env-files/nijobs-be/develop/.env.local'

# Essential, duh! :)
export project_port
export project_dotenv_location
export project_docker_flags
export configured_projects
