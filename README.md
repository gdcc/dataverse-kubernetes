![](https://raw.githubusercontent.com/IQSS/dataverse-kubernetes/master/docs/title-composition.png)

# Running Dataverse on Kubernetes

[![Dataverse](https://img.shields.io/badge/Dataverse-v4.15-important.svg)](https://dataverse.org)
[![Test Status](https://travis-ci.org/IQSS/dataverse-kubernetes.svg?branch=master)](https://travis-ci.org/IQSS/dataverse-kubernetes)
[![Docker Hub Image](https://img.shields.io/static/v1.svg?label=image&message=dataverse-k8s&logo=docker)](https://hub.docker.com/r/iqss/dataverse-k8s)
[![Docker Hub Image](https://img.shields.io/static/v1.svg?label=image&message=solr-k8s&logo=docker)](https://hub.docker.com/r/iqss/solr-k8s)

This community-supported project aims to provide a simple to re-use example on how to run
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

For quick and easy demo purposes, you can use one of the examples:

* [Quick demo with Minikube](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/minikube.md)
* [Usage with minimized k3s](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/k3s.md)
* [Deploy to an Amazon EC2 based custom K8s cluster](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/aws-kops.md)

For production usage, you should make yourself familiar with a series of
documentation articles, linked below:

* [Container images](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/images.md)
* [Detailed insight into inner workings](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/how-it-works.md)
* [Using Kubernetes descriptors from this project](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/reuse.md)
* [Configuration of Dataverse](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/config.md)
* [Secrets usage](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/secrets.md)

Please be aware that this project currently only offers images and support
for basic usage. Integrations are not yet part of this, but may be added as needed.
See also relevant docs within Dataverse guides and upstream projects.

A number of utilities have been added for your convienience:
have a look at [Little Helpers](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/little-helpers.md).

### Upgrading your installation

When switching to a new Dataverse version (you will need to change the image tag),
please always [read upstream release notes carefully](https://github.com/IQSS/dataverse/releases).

Obviously, deployments or changed files are included in the images, but
sometimes, you will need to execute some actions manually.

These actions are left out of automation by intent. For example re-indexing
might be a heavy lifting task in your installation and put heavy load on your
deployment (you might want to schedule that for off-hours).

We will try to point out any of those in release notes of our k8s images.

## Support

This project is supported by the Dataverse community rather than IQSS. If you need help, please open an issue.

## Future plans and ideas

At a later point in time, an [Operator](https://coreos.com/operators/) might be
added for even easier usage.

The docker images should at some point be moved into the upstream code,
so they can be build and used for development purposes, too.
See also [issue 5292](https://github.com/IQSS/dataverse/issues/5292) on this.

This should support testing S3 remote file storage with Minio out of the box.
