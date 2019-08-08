# Apache configs for Ni's server

`apache2` configs for Ni's server.

## Requirements

Requires that niserver has apache2 and bash installed, as one would expect :upside\_down:

Current apache version (will probably quickly become outdated, verify this always before relying on it): 2.4.29


## Structure

- `config-modules`: Useful modular config files, used via [`Include`](https://httpd.apache.org/docs/2.4/mod/core.html#include) directives in site definitions in order to remove config code repetition.
- `sites`: Site definitions (`VirtualHosts` and such)
- `enabled_sites`: Currently enabled sites. See [enabling sites](#enabling-sites) for details.


## Adding a site

To add a site, just add its configuration to the `sites` directory. Make sure to keep the configuration as short as possible, using and adding to the files in `config-modules/`.

If possible, test the configuration in your computer, including running `apachectl configtest` to verify the validity of the syntax.

After adding a site, don't forget that is not enabled by default. See [this section](#enabling-sites) for details on how to enable a site.


## Enabling sites

To enable sites, just add them to the `enabled_sites` text file, one per line. The name should match the one in the `sites` directory.
For example, to enable the sites defined by the files `000-default.conf` and `000-default-ssl.conf` (inside the `sites` directory), the `enabled_sites` text file should be:

```
000-default.conf
000-default-ssl.conf
```


## Updating the server configs

To update the server configs, just run the provided `update_apache_config.sh` script.

Consult if the startup was successful using `systemctl status apache2`.


---

TODO:

- rename sites (000 stuff to something decent)
- think about the best arch in terms of where the config-modules files should be and where they should be referenced -> when to use env vars too
