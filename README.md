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
kubectl create -f k8s/pv-hostPath.yaml
```

Now let's create some secrets that will be used for Postgres, DataCite DOI
registration and Rserve:
```
kubectl create secret generic dataverse-postgresql --from-literal=username='dataverse' --from-literal=password='changeme'
kubectl create secret generic dataverse-rserve --from-literal=username='rserve' --from-literal=password='changeme'
kubectl create secret generic dataverse-doi --from-literal=username='test.doi' --from-literal=password='changeme'
```

Let's deploy PostgreSQL and Solr now:
```
kubectl create -f k8s/postgres.yaml
kubectl create -f k8s/solr.yaml
```

Once PostgreSQL and Solr are ready, deploy Dataverse:
```
kubectl create -f k8s/dataverse.yaml
```

When the deployment was successfull (check with `kubectl logs dataverse-...`),
you need to bootstrap the installation:
```
kubectl create -f k8s/bootstrap.yaml
```

More is WIP. For now, you can do a `kubectl port-forward` of dataverse pod port 8080
and you should then see a login at http://localhost:8080 in your browser.

## Future plans and ideas

At a later point in time, an [Operator](https://coreos.com/operators/) might be
added for even easier usage.

The docker images should at some point be moved into the upstream code,
so they can be build and used for development purposes, too.
See also [issue 5292](https://github.com/IQSS/dataverse/issues/5292) on this.

This should support testing S3 remote file storage with Minio out of the box.
