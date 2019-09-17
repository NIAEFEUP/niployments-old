#!/usr/bin/env bash

# Script to be ran by cron in order to periodically deploy NIAEFEUP's projects!

# Add this to cron to be ran every 30 minutes using:
# echo "*/30 * * * * PATH_TO_THIS_SCRIPT" | crontab
# Check the configured jobs using crontab -l or crontab -e
# See crontab(1) for further details

# Forking only per project as running two deploys for the same project at the same time will
# result in aborting due to the lock not being acquired (being held by the other deployment)

# Configure the projects to automatically deploy below here

# nijobs-be
(./deploy.sh --cron-mode nijobs-be master; ./deploy.sh --cron-mode nijobs-be develop) &

# nijobs-fe
(./deploy.sh --cron-mode nijobs-fe master; ./deploy.sh --cron-mode nijobs-fe develop) &

# NIAEFEUP-Website
# Currently on hold until some changes are done
# (./deploy.sh --cron-mode NIAEFEUP-Website master; ./deploy.sh --cron-mode NIAEFEUP-Website develop) &

# tts-fe
# Currently on hold until the React port is done
# (./deploy.sh --cron-mode tts-fe master; ./deploy.sh --cron-mode tts-fe develop) &
