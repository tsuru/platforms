# static platform

The static platform provides a nginx setup that serves anything that is in the
application directory. A simple application with just an index.html file can be
easily deployed to tsuru.

## Customizing nginx configuration

It's possible to customize nginx configuration by simply placing a file named
nginx.conf in the root of the project. The default configuration file is
[available in this
repository](https://github.com/tsuru/platforms/blob/master/static/etc/nginx.conf).
A common practice is to copy it and then do some customizations, as it contains
some mandatory directives for proper behavior on tsuru (like ``port_in_redirect
off``).
