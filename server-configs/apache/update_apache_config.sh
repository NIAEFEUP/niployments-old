#!/usr/bin/env bash

# Helper script to apply the apache configurations found inside this directory

# See https://sipb.mit.edu/doc/safe-shell/
set -ueo pipefail

# Disabling the currently existing sites (so that they are not lost, but do not interfer with the configurations, which should all be done using this tool)
# This finds all the sites (files) in sites-available and gets their basename (file name without path) to pass to a2dissite (thus disabling them)
find /etc/apache2/sites-available/ -type f -print0 | xargs -0 basename -a | xargs a2dissite &> /dev/null

# To verify if they exist
unset CONFIG_MODULES_DIR
unset CERTIFICATES_DIR
unset DEPLOYMENTS_DIR

## It is necessary to get the apache environment variables specified in the README

# First disabling the check for unset variables as apache envvars file references some:
set +u

# Then sourcing the file:
# The following directive is so shellcheck doesn't try to follow the source command
# shellcheck source=/dev/null
source /etc/apache2/envvars

# Reenabling safety checks for unset vars
set -u

# Checking envvars definition
if [[ -z "${CONFIG_MODULES_DIR:-}" ]] || [[ -z "${CERTIFICATES_DIR:-}" ]] || [[ -z "${DEPLOYMENTS_DIR:-}" ]]; then
    echo "Error: At least one of the environment variables specified in the README is not configured."
    exit 1
fi

# Copying the sites and config-modules configurations to the correct directories.
cp sites/* /etc/apache2/sites-available/
cp config-modules/* "$CONFIG_MODULES_DIR"

# Reads the enabled_sites file into the enabled_sites variable as an array, one line=one item
# See https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-readarray
readarray -t sites_to_enable < enabled_sites

echo "Will enable the following sites: " "${sites_to_enable[@]}"

for enabled_site in "${sites_to_enable[@]}"; do
    sudo a2ensite "$enabled_site"
    echo "Enabled site: $enabled_site"
done

echo "Restarting apache"
sudo systemctl restart apache2
