# Apache configs for Ni's server

`apache2` configs for Ni's server.

## Requirements

Requires that niserver has apache2 and bash installed, as one would expect :upside\_down:

Current apache version (will probably quickly become outdated, verify this always before relying on it): 2.4.29

Since the configs were changed to become more modular, they also require the configuration of apache envvars to work correctly.
See [configuring apache envvars](#configuring-apache-envvars) for details on how to do this.

Additionally, the apache server will have to have the following mods enabled:
* `expires` (For `files.conf` setting cache expiration on things)
* `rewrite` (For enabling RewriteEngine and related stuff in `routing.conf`)
* `proxy_http` (For the reverse proxying in `routing.conf`)
* `ssl` for obvious reasons I'd say? :grin:


## Structure

- `config-modules`: Useful modular config files, used via [`Include`](https://httpd.apache.org/docs/2.4/mod/core.html#include) directives in site definitions in order to remove config code repetition.
- `sites`: Site definitions (`VirtualHosts` and such)
- `enabled_sites`: Currently enabled sites. See [enabling sites](#enabling-sites) for details.


## Adding a site

To add a site, just add its configuration to the `sites` directory. Make sure to keep the configuration as short as possible, using and adding to the files in `config-modules/`.

If possible, test the configuration in your computer, including running `apachectl configtest` to verify the validity of the syntax.

After adding a site, don't forget that is not enabled by default. See [this section](#enabling-sites) for details on how to enable a site.

**Note:** When extending what was done in `routing.conf`, if using automated deployments via Docker, do not use `http://nitmp.fe.up.pt:3000` (3000 is just an example, this goes for any port) as this will not work.
Use `http://localhost:3000` instead. I'm not entirely sure why this happens but it was the case when setting the server back up again.
As such, using localhost is recommended since it works for both cases.


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


## Configuring apache envvars

The configuration of some apache envvars is necessary for these configurations to work as expected.
They should be configured in `/etc/apache2/envvars` (the default apache envvars file). See [this for details](https://geek-university.com/apache/envvars-file/) (or google `apache envvars`).

They are the following:

- `CONFIG_MODULES_DIR` - The directory in which the files in `config-modules` are stored, so that they can be included in the site definition files.
- `CERTIFICATES_DIR` - The directory where SSL certificates and such are stored (probably something like `/home/ubuntu/certificates/`).
