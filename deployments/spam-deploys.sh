#!/usr/bin/env bash

curr_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$curr_dir" ]]; then curr_dir="${0%/*}"; fi

# Script to be ran by cron in order to periodically deploy NIAEFEUP's projects!

# Add this to cron to be ran every 30 minutes using:
# echo "*/30 * * * * PATH_TO_THIS_SCRIPT" | crontab
# Check the configured jobs using crontab -l or crontab -e
# See crontab(1) for further details

# Forking only per project as running two deploys for the same project at the same time will
# result in aborting due to the lock not being acquired (being held by the other deployment)

# Configure the projects to automatically deploy below here

# nijobs-be
("$curr_dir/deploy.sh" --cron-mode nijobs-be master; "$curr_dir/deploy.sh" --cron-mode nijobs-be develop) &

# nijobs-fe
("$curr_dir/deploy.sh" --cron-mode nijobs-fe master; "$curr_dir/deploy.sh" --cron-mode nijobs-fe develop) &

# NIAEFEUP-Website
# Currently on hold until some changes are done
# ("$curr_dir/deploy.sh" --cron-mode NIAEFEUP-Website master; "$curr_dir/deploy.sh" --cron-mode NIAEFEUP-Website develop) &

# tts-fe
# Currently on hold until the React port is done
# ("$curr_dir/deploy.sh" --cron-mode tts-fe master; "$curr_dir/deploy.sh" --cron-mode tts-fe develop) &
