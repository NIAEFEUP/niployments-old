#!/usr/bin/env bash

# Configuration of each project's port and env file location
# Uses bash dictionaries: https://devhints.io/bash#dictionaries

# The dictionary keys must be in the format "${project_github_id}---${branch}" (see examples below)
# The dotenv location is not mandatory, but if given it must exist.

declare -A project_port
declare -A project_dotenv_location

# NIAEFEUP-Website
project_port[NIAEFEUP-Website---master]=3000
project_dotenv_location[NIAEFEUP-Website---master]='/home/ni/niployments/deployments/env-files/NIAEFEUP-Website/master/.env'

# (Thanks to this modular config, it is possible to also deploy staging (painlessly!))
# nijobs-fe
project_port[nijobs-fe---master]=4001
# project_dotenv_location[nijobs-fe---master]='/home/ni/niployments/deployments/env-files/nijobs-fe/master/.env'
## nijobs-fe staging
project_port[nijobs-fe---develop]=4002
# project_dotenv_location[nijobs-fe---develop]='/home/ni/niployments/deployments/env-files/nijobs-fe/master/.env'

# nijobs-be
project_port[nijobs-be---master]=4010
project_dotenv_location[nijobs-be---master]='/home/ni/niployments/deployments/env-files/nijobs-be/master/.env.local'
## nijobs-be staging
project_port[nijobs-be---develop]=4011
project_dotenv_location[nijobs-be---develop]='/home/ni/niployments/deployments/env-files/nijobs-be/develop/.env.local'
# debug example:
# project_dotenv_location[nijobs-be---develop]='/home/miguel/Coding/NIAEFEUP/niployments/deployments/env-files/nijobs-be/develop/.env.local'


# Essential, duh! :)
export project_port
export project_dotenv_location
