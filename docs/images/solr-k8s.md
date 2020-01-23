# Image "solr-k8s"

[![Upstream](https://img.shields.io/badge/Dataverse-v4.18-important.svg)](https://github.com/IQSS/dataverse/releases/v4.18)
[![Hub](https://img.shields.io/static/v1.svg?label=image&message=solr-k8s&logo=docker)](https://hub.docker.com/r/iqss/solr-k8s)
[![Solr](https://img.shields.io/static/v1.svg?label=upstream&message=7.3.1&logo=docker)](https://hub.docker.com/_/solr)
![Pulls](https://img.shields.io/docker/pulls/iqss/solr-k8s)
[![RTD](https://img.shields.io/readthedocs/dataverse-k8s)](https://dataverse-k8s.readthedocs.io)
[![Build](https://jenkins.dataverse.org/job/dataverse-k8s/job/image-solr/job/master/badge/icon?subject=master&status=pushed&color=purple)](https://jenkins.dataverse.org/job/dataverse-k8s/job/image-solr/job/master)

This container image includes a dependency service to run [Dataverse](https://dataverse.org), a
Java EE based web application for research data management, on a container platform.
It is derived from [upstream Solr images](https://hub.docker.com/_/solr), [using the
required version](http://guides.dataverse.org/en/4.18/installation/prerequisites.html#solr).

It is primarily targeted to be used in production on [Kubernetes](https://kubernetes.io),
but if you follow the same conventions, you should be able to use it with other tools
like [Docker](https://docker.io) or [podman](https://podman.io).

## Supported tags

- `latest`: master branch based build ([`Dockerfile`](https://github.com/IQSS/dataverse-kubernetes/blob/master/docker/dataverse-k8s/glassfish/Dockerfile))
- `4.18`, ..., `4.15.1`, ..., `4.11`: stable (tagged) releases
  - Using [upstream release schema](https://github.com/IQSS/dataverse/releases/) down to `4.11`.
  - See also [list on Docker Hub](https://hub.docker.com/r/iqss/dataverse-k8s/tags?page=1&ordering=last_updated&name=4.)
    for releases
  - Last stable tag ([`Dockerfile`](https://github.com/IQSS/dataverse-kubernetes/blob/v4.18/docker/solr-k8s/Dockerfile))

## Quick reference

Below you will find some documentation about the image itself.
To fully understand how to use it, you should go to the
[*Dataverse Cloud & Container Guide*](https://dataverse-k8s.rtfd.io).
(This file is part of it.)

Please remember that the collection name is hardcoded in Dataverse as `collection1`
and available as `$COLLECTION`.

### Important Directories

This image possesses a user `solr` with `uid=8983`. The Solr index server
is running as `solr`, **not** `root`. Please remember to grant write permission
to this user on any volumes used for the below directories.

- **/opt/solr/server/solr/collection1/conf** <br />
  Configuration files like `solrconfig.xml`, `schema.xml` plus default
  `schema_dv_mdb_copies.xml` and `schema_dv_mdb_fields.xml` live here.
  Also available as `$COLLECTION_DIR/conf`.
- **/opt/solr/server/solr/collection1/data** <br />
  Mount a volume to persist the actual index. Also available as `$COLLECTION_DIR/data`.
- **/schema** <br />
  You can place your customized Solr Index fields configuration here.
  Solr will try to read from `schema_dv_mdb_copies.xml` and `schema_dv_mdb_fields.xml`
  on startup or fallback to those shipped with the image (see above).
  Also available as `$SCHEMA_DIR`

  Please read the detailed docs about Solr schema provisioning:
   - [Upstream: updating Solr schema](http://guides.dataverse.org/en/4.18/admin/metadatacustomization.html#updating-the-solr-schema).
   - [Kubernetes `Job`s for Search Index](https://dataverse-k8s.rtfd.io/en/4.18/day2/job-index.html)
- **/scripts** <br />
  A collection of scripts for init containers and sidecars. See guide for more
  information on those scripts. Also available as `$SCRIPT_DIR`.

### Secrets and Credentials

This container does not use any secrets or credentials right now.

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
