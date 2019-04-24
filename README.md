![](docs/title-composition.png)

# Running Dataverse on Kubernetes

[![Dataverse](https://img.shields.io/badge/Dataverse-v4.13-important.svg)](https://dataverse.org)
[![Test Status](https://travis-ci.org/IQSS/dataverse-kubernetes.svg?branch=master)](https://travis-ci.org/IQSS/dataverse-kubernetes)
[![Docker Hub Image](https://img.shields.io/static/v1.svg?label=image&message=dataverse-k8s&logo=docker)](https://cloud.docker.com/u/iqss/repository/docker/iqss/dataverse-k8s)
[![Docker Hub Image](https://img.shields.io/static/v1.svg?label=image&message=solr-k8s&logo=docker)](https://cloud.docker.com/u/iqss/repository/docker/iqss/solr-k8s)

This project aims to provide a simple to re-use example on how to run
Dataverse on a Kubernetes cluster.

**NOTE:** all Docker images in this project work for released versions of
Dataverse only!

## Prerequisites

You'll need a running and fully configured Kubernetes cluster either
using OpenShift, Minikube, a full-fledged Cluster, GKE or similar.

When you want to register datasets and/or files in your deployment to
DataCite, EZID or similar, you will need working accounts to configure.
Otherwise, you might want to use the FAKE provider.
See also: http://guides.dataverse.org/en/latest/installation/config.html
and https://github.com/IQSS/dataverse/issues/5448

## Usage

Depending on the type of deployment you are going to achieve, you will need to
use the k8s YAML files in the `k8s` directory as an example to get you started.

For production usage you really will want to fork and create your on deployments.
(At least as long as no Operator or Helm chart exists for this...)

Example usages:
* [Quick demo with Minikube](docs/minikube.md)

### Upgrading your installation

When switching to a new Dataverse version (you will need to change the image tag),
please always [read upstream release notes carefully](https://github.com/IQSS/dataverse/releases).

Obviously, deployments or changed files are included in the images, but
sometimes, you will need to execute some actions manually.

These actions are left out of automation by intent. For example re-indexing
might be a heavy lifting task in your installation and put heavy load on your
deployment (you might want to schedule that for off-hours).

We will try to point out any of those in release notes of our k8s images.

## Configuration of Dataverse
Configuring dataverse is done in different places. Some things for more "basic"
system configuration is done in Java system properties, residing in the Glassfish
domain configuration. More advanced and flexible options are stored in the
database and configured via API and/or UI.

* See [JVM Options](http://guides.dataverse.org/en/latest/installation/config.html#jvm-options)
  for system properties.
* See [Database Settings](http://guides.dataverse.org/en/latest/installation/config.html#database-settings)
  for all other settings.

Things like file storage, networking, DOI, etc are all *basic system settings*
and can be set via system properties. For your convienience, these can be
stored in a `ConfigMap`.

Some things need sane defaults, which can be found in [default.config](./dataverse-k8s/bin/default.config).
You might find those usefull as an example for your personally tuned `ConfigMap`.

### Mapping environment variables to JVM options
The basic idea is to map environment variables to Java system properties each
time a Dataverse container starts with the default entrypoint (being the application
server).

1. Simply pick a [JVM Option](http://guides.dataverse.org/en/latest/installation/config.html#jvm-options)
   from the list and replace "." with "_" ("-" is not allowed in env var names!).
2. Put the transformed name as a key into the `ConfigMap` `.data`.
3. Add your value. Be sure to use simple strings only - no numbers, no complex types.

Example:
```yaml
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: dataverse
  labels:
    app: dataverse
data:
  dataverse_fqdn: data.example.org
  dataverse_siteUrl: https://\${dataverse.fqdn}
  doi_username: test.account
  dataverse_auth_password__reset__timeout__in__minutes: 30
```
**DO NOT USE THIS FOR PASSWORDS!** Those are done via k8s secrets, see below.

Currently some JVM options have dashes in them, which is no allowed character for
an environment variable. As a workaround, replace any dash with `__`. It will
be transformed back into `-` internally when the container starts. See example above.

### Mapping environment variables to Database settings
As database settings are persistent in, well, the database, they don't need
to get set everytime the container starts. To be consistent and easy to use,
the same `ConfigMap` used for JVM options can be used for these settings,
but you need to create a `Job` or even a `CronJob` to apply them.

*Note:* Of course you can choose to use your own tools and scripts for this.
Basically its just `curl` calls to the Admin API.

#### Provide a setting

1. Pick a [Database setting](http://guides.dataverse.org/en/latest/installation/config.html#database-settings)
2. Remove the `:` and replace it with `db_`. Keep the Pascal case!
3. Put the transformed value into the `ConfigMap` `.data`.
4. Add your value, which can be any value you see in the docs. Keep in mind:
   when you need to use JSON, format it as a string!

Example:
```yaml
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: dataverse
  labels:
    app: dataverse
data:
  # Skipping JVM options here. See above.
  db_SystemEmail: "Ghostbusters <slimer@buh.net>"
  db_Languages: '[{ "locale":"en", "title":"English" }, { "locale":"fr", "title":"Français" }]'
```
**DO NOT USE THIS FOR PASSWORDS OR KEYS!** Those are done via k8s secrets, see below.

#### Delete a setting
When you need to **delete** a setting, just provide an *empty* value.

#### Apply settings
Remember: you will need to update the `ConfigMap` when you want to apply changes.
You need to think about in which file you keep the map - having it in two locations
is a bad idea. It's always a good idea to put it in revision control.

```
# Updated ConfigMap inside:
kubectl apply -f k8s/dataverse.yaml
# Deploy the config job:
kubectl apply -f k8s/utils/configure-job.yaml
```

You might consider providing a `CronJob` for scheduled, regular updates.

### Handling passwords with K8s Secrets
Please use [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) and *mount them as volumes*.
See also [here](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#create-a-pod-that-has-access-to-the-secret-data-through-a-volume).

Currently understood secrets in the container, mounted at `SECRETS_DIR=/opt/dataverse/secrets`:
1. `rserve/password` - optional, only needed when using a RServe server.
2. `doi/password` - needed when you use DOIs for PIDs.
3. `db/password` - required - guess why?
4. `api/key` - required because you want the *unblock-key* for anything serious.
5. `s3/access-key` and `s3/secret-key` - needed when you want to use S3 storage. See #28.

A password alias is automatically created and used for those, no need to provide
those yourself. (see [default.config](./dataverse-k8s/bin/default.config))

You can of course map other parts of the secret like usernames to an environment
variable like `doi_username` etc.

### Use a `Secret` to configure PostgreSQL connection details
You may use the *dataverse-postgres* secret above to configure database name,
database user and password without adding these details to the `ConfigMap`.

Customize the following example to use it:
```
kubectl create secret generic dataverse-postgresql \
            --from-literal=username='dataverse' \
            --from-literal=password='changeme' \
            --from-literal=database='mydataverse'
```

## Little Helpers
### Inplace Re-Index Job
Sometimes when you upgrade to a new Dataverse version, the Solr configuration
has been changed by upstream. In these cases, release notes will advise you to
[do an "inplace reindex"](http://guides.dataverse.org/en/latest/admin/solr-search-index.html#reindex-in-place).

For your convienience, a batch job has been added containing actions mentioned
in the docs for you. Simply deploy it during off-hours (or fork and create a CronJob):
```
kubectl apply -f k8s/dataverse/jobs/inplace-reindex.yaml
```

### Catching emails from Dataverse easily
While doing a showcase, developing or other purposes, it comes in handy
to see what emails are sent by Dataverse.
Instead of relying on an external service as Mailinator, Mailtrap.io or similar,
just use [MailCatcher](https://mailcatcher.me/) as a small extra deployment:

```bash
kubectl create -f k8s/utils/mailcatcher.yaml
minikube service mailcatcher
```
(The last will open the web UI in your default browser.)

The SMTP server can be used via `postfix:25`, which is also the default config
for Dataverse when you "just use" the deployments found in `k8s/`. (It will
*"Just Work (TM)"*).

**Please note** that all sent mails will be **deleted** when you restart or
delete the deployment/pod/container.

## Future plans and ideas

At a later point in time, an [Operator](https://coreos.com/operators/) might be
added for even easier usage.

The docker images should at some point be moved into the upstream code,
so they can be build and used for development purposes, too.
See also [issue 5292](https://github.com/IQSS/dataverse/issues/5292) on this.

This should support testing S3 remote file storage with Minio out of the box.
