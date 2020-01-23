# Image "dataverse-k8s"

[![Upstream](https://img.shields.io/badge/Dataverse-v4.18.1-important.svg)](https://github.com/IQSS/dataverse/releases/v4.18.1)
[![Hub](https://img.shields.io/static/v1.svg?label=image&message=dataverse-k8s&logo=docker)](https://hub.docker.com/r/iqss/dataverse-k8s)
![Pulls](https://img.shields.io/docker/pulls/iqss/dataverse-k8s)
[![RTD](https://img.shields.io/readthedocs/dataverse-k8s)](https://dataverse-k8s.readthedocs.io)
[![Build](https://jenkins.dataverse.org/job/dataverse-k8s/job/image-dataverse/job/master/badge/icon?subject=master&status=pushed&color=purple)](https://jenkins.dataverse.org/job/dataverse-k8s/job/image-dataverse/job/master)

This container image enables you to run [Dataverse](https://dataverse.org), a
Java EE based web application for research data management, on a container platform.

It is primarily targeted to be used in production on [Kubernetes](https://kubernetes.io),
but if you follow the same conventions, you should be able to use it with other tools
like [Docker](https://docker.io) or [podman](https://podman.io).

## Supported tags

- `latest`: master branch based build ([`Dockerfile`](https://github.com/IQSS/dataverse-kubernetes/blob/master/docker/dataverse-k8s/glassfish/Dockerfile))
- `build-cache`: a maven cache image to speedup dev builds, refreshed every night based on latest upstream `develop`. ([`Dockerfile`](https://github.com/IQSS/dataverse-kubernetes/blob/master/docker/dataverse-k8s/build-cache/Dockerfile), [`Jenkinsfile`](https://github.com/IQSS/dataverse-kubernetes/blob/master/docker/dataverse-k8s/build-cache/Jenkinsfile))
- `4.18.1`, ..., `4.15.1`, ..., `4.11`: stable (tagged) releases
  - Using [upstream release schema](https://github.com/IQSS/dataverse/releases/) down to `4.11`.
  - See also [list on Docker Hub](https://hub.docker.com/r/iqss/dataverse-k8s/tags?page=1&ordering=last_updated&name=4.)
    for releases
  - Last stable tag ([`Dockerfile`](https://github.com/IQSS/dataverse-kubernetes/blob/v4.18.1/docker/dataverse-k8s/glassfish/Dockerfile))

## Quick reference

Below you will find some documentation about the image itself.
To fully understand how to use it, you should go to the
[*Dataverse Cloud & Container Guide*](https://dataverse-k8s.rtfd.io).
(This file is part of it.)

### Important Directories

This image possesses a user `dataverse` with `uid=1000`. The application server
is running as `dataverse`, **not** `root`. Please remember to grant write permission
to this user on any volumes (except secrets) used for the below directories.

- **/secrets** <br />
  Mount [secrets](#secrets-and-credentials) tree here. Also available as `$SECRETS_DIR`.

- **/data** <br />
  Mount a volume to save uploaded research data here. Used for temporary file storage only
  when using a remote storage like S3. You might need to replicate this data or place
  on a shared filestorage in multi-instance installations. Also available as `$DATA_DIR`.

- **/metadata** <br />
  Mount a volume here or use an init/sidecar container to deploy your [custom metadata
  blocks in TSV format](http://guides.dataverse.org/en/latest/admin/metadatacustomization.html).
  Also available as `$METADATA_DIR`. <small>Upstream metadata blocks are stored at
  `/opt/dataverse/dvinstall/data/metadatablocks`.</small>

- **/docroot** <br />
  Mount a volume here to store i18n language bundle files, sitemaps, images for
  Dataverses, logos, custom themes and stylesheets, etc here. You might need to
  replicate this data or place on a shared filestorage in multi-instance installations.
  Also available as `$DOCROOT_DIR`.

- **/opt/dataverse/...** <br />
  Installation root of application server, WAR files, scripts etc. See `Dockerfile`
  for all details.

### Secrets and Credentials

Currently understood secrets in the container, mounted at `$SECRETS_DIR` (see
above) as a tree of directories and files:

1. `rserve/password` - optional, only needed when using a RServe server.
2. `doi/password` - needed when you use DOIs for PIDs.
3. `db/password` - required - guess why?
4. `api/key` - required because you want the *unblock-key* for anything serious.
5. `s3/access-key` and `s3/secret-key` - needed when you want to use S3 storage. See docs on using S3.
6. `admin/password` - optional, provision a password for the `dataverseAdmin` account. Defaults to `admin1`.
7. `api/userskey` - optional, provision a `BuiltinUsers.KEY`, which is necessary to create builtin users via API. Defaults to not available.

A [password alias](https://docs.oracle.com/cd/E19798-01/821-1751/ghgqc/index.html)
is automatically created and used for those that are set via JVM options, no need
to provide them yourself.

During container startup, environment variables are used inside entrypoint scripts
for the non-secret parts of credentials. See [default.config](https://dataverse-k8s.readthedocs.io/en/latest/day1/config.html#default-config)
for a list.

More about secrets can be found in [the guide](https://dataverse-k8s.readthedocs.io/en/latest/day1/secrets.html).

### Update policy

Please be aware that future enhancements to scripting and more used to deploy and
configure Dataverse will not be added to old releases ("fix forward").

Nonetheless, only the `latest` and current stable image tag will receive any (security)
updates released for underlying images. This happens as a scheduled build each
night, pushing to Docker Hub. Please take care of updating, depending on your deployment.

You should be encouraged to update to the latest release ASAP.
If you need to stay with a certain version, please feel free to [open an issue](https://github.com/IQSS/dataverse-kubernetes/issues/new).

### Support Disclaimer

This image is maintained and supported by the Dataverse community. IQSS, Harvard, Cambridge
is not providing support for it. Please find details how to contact the maintainers
in the [*Dataverse Cloud & Container Guide*](https://dataverse-k8s.rtfd.io).
