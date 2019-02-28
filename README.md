# Running Dataverse on Kubernetes

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

### Test deployment with Minikube

Suggesting you have a working [Minikube](https://kubernetes.io/docs/setup/minikube/)
installation at hands. If not, follow the instructions to get started.

First you will need to create a physical volume to store data on:
```
kubectl create -f k8s/utils/pv-hostPath.yaml
```

Now let's create some secrets that will be used for Postgres, DataCite DOI
registration and Rserve:
```
kubectl create secret generic dataverse-postgresql --from-literal=username='dataverse' --from-literal=password='changeme'
kubectl create secret generic dataverse-rserve --from-literal=username='rserve' --from-literal=password='changeme'
kubectl create secret generic dataverse-doi --from-literal=username='test.doi' --from-literal=password='changeme'
kubectl create secret generic dataverse-api --from-literal=key='supersecret'
```

Let's deploy PostgreSQL and Solr now:
```
kubectl create -f k8s/postgresql.yaml
kubectl create -f k8s/solr.yaml
```

Once PostgreSQL and Solr are ready, deploy Dataverse:
```
kubectl create -f k8s/dataverse.yaml
```

When the deployment was successfull, you need to bootstrap the installation.
You can simply create the job, it will wait for Dataverse to deploy.
```
kubectl create -f k8s/bootstrap.yaml
```

You can check the status of the containers and the bootstrapping job from
the output of `kubectl get pods,jobs`.

If you want to use this basic deployment for development, testing or demo cases,
you can just execute the following to open Dataverse in your browser:
```
kubectl expose deployment dataverse --type=NodePort --name=dataverse-local
minikube service dataverse-local
```

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

### Mapping environment variables to options
The basic idea is to map environment variables to Java system properties when
the container starts.

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
```
**DO NOT USE THIS FOR PASSWORDS!** Those are done via k8s secrets, see below.

Currently, two JVM options have "-" in them, which is no allowed character for
an environment variable.
1. For "dataverse.auth.password-reset-timeout-in-minutes" use "dataverse_auth_password_reset_timeout".
2. For "dataverse.files.hide-schema-dot-org-download-urls" no alias exists, as it's experimental.

### Handling passwords with K8s Secrets
Please use [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) and *mount them as volumes*.
See also [here](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#create-a-pod-that-has-access-to-the-secret-data-through-a-volume).

Currently understood secrets in the container, mounted at `SECRETS_DIR=/opt/dataverse/secrets`:
1. `rserve/password` - optional, only needed when using a RServe server.
2. `doi/password` - needed when you use DOIs for PIDs.
3. `db/password` - required no matter what...

A password alias is automatically created and used for those, no need to provide
those yourself. (see [default.config](./dataverse-k8s/bin/default.config))

You can of course map other parts of the secret like usernames to an environment
variable like `doi_username` etc.

## Little Helpers
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
