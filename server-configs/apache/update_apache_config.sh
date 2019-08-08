#!/usr/bin/env bash

# See https://sipb.mit.edu/doc/safe-shell/
set -ueo pipefail

# Copying the sites configuration to the apache directory.
# TODO: Discuss: Should these be symlinks instead?
# TODO: Discuss: Should the existing configs be cleared? (available/enabled) This would force all configs to be done via 'niployments'. Is that bad or good? Probably good but should still discuss it.
cp sites/* /etc/apache2/sites-available/

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
