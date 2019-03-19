# Tweaked Apache HTTPd image

This image is based on [upstream](https://hub.docker.com/_/httpd) Docker
image of Apache HTTPd 2.4.

## Configuration

It contains a little tweak to include configuration files in
`/usr/local/apache2/conf/k8s`, so it gets easy to mount volumes or put a config
from `ConfigMap` in there, which is auto-included on startup.

Files are included using `IncludeOptional conf/k8s/*.conf`, thus you need
to put your configuration in files with a `.conf` suffix. Remember the glob
sort order: you can prepend with things like `10_`, `20_`, ... to order the
inclusion. This is often usefull for vHosts or loading modules before other parts.

## Tags

Upstream image contains all modules Apache HTTPd has included.
This repo contains some tagged images which contain extra modules:

* `-mellon` adds [Uninett mod_auth_mellon](https://github.com/Uninett/mod_auth_mellon)
   for usage as a simple SAML 2.0 Service Provider and enables it to autoload on startup.
