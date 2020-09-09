#!/usr/bin/env bash

spam_deploys_curr_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$spam_deploys_curr_dir" ]]; then spam_deploys_curr_dir="${0%/*}"; fi

# Script to be ran by cron in order to periodically deploy NIAEFEUP's projects!

# Add this to cron to be ran every 30 minutes using:
# echo "*/30 * * * * PATH_TO_THIS_SCRIPT" | crontab
# Check the configured jobs using crontab -l or crontab -e
# See crontab(1) for further details

# Forking only per project as running two deploys for the same project at the same time will
# result in aborting due to the lock not being acquired (being held by the other deployment)

# Configure the projects to automatically deploy below here

# nijobs-be
(
    "$spam_deploys_curr_dir/deploy.sh" --cron-mode nijobs-be master;
    "$spam_deploys_curr_dir/deploy.sh" --cron-mode nijobs-be develop
) &

# nijobs-fe
(
    "$spam_deploys_curr_dir/deploy.sh" --cron-mode nijobs-fe master;
    "$spam_deploys_curr_dir/deploy.sh" --cron-mode nijobs-fe develop;
    "$spam_deploys_curr_dir/deploy.sh" --cron-mode nijobs-fe experimental
) &

# Website-NIAEFEUP 
# Currently on hold until a solution for uploaded resources  
# is reached to store them outside the container
# (
    # "$spam_deploys_curr_dir/deploy.sh" --cron-mode Website-NIAEFEUP master;
    # "$spam_deploys_curr_dir/deploy.sh" --cron-mode Website-NIAEFEUP develop
# ) &

# tts-fe
# Currently on hold until the React port is done
(
    "$spam_deploys_curr_dir/deploy.sh" --cron-mode tts-fe master;
    # "$spam_deploys_curr_dir/deploy.sh" --cron-mode tts-fe develop
) &
