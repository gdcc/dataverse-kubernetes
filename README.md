![](https://raw.githubusercontent.com/IQSS/dataverse-kubernetes/master/docs/title-composition.png)

# Running Dataverse on Kubernetes

[![Dataverse](https://img.shields.io/badge/Dataverse-v4.16-important.svg)](https://dataverse.org)
[![Validation](https://jenkins.dataverse.org/job/dataverse-k8s/job/Kubeval%20Linting/job/master/badge/icon?subject=kubeval&status=valid&color=purple)](https://jenkins.dataverse.org/job/dataverse-k8s/job/Kubeval%20Linting/job/master/)
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

*Quick'n'dirty demo on naked cluster:*
```
kubectl apply -k .
```

**Notes:**
- This will of course need a recent `kubectl` and a configured cluster context.
- This is usable for demo purposes.
- You really want to [provide a secure admin password](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/secrets.md) for anything serious.

#### Production usage
You should make yourself familiar with a series of documentation articles, linked below:

* [Container images](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/images.md)
* [Persistance storage](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/storage.md)
* [Detailed insight into inner workings](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/how-it-works.md)
* [Using Kubernetes descriptors from this project](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/reuse.md)
* [Configuration of Dataverse](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/config.md)
* [Secrets usage](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/secrets.md)
* [(Custom) Metadata Blocks](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/metadata.md)
* [Maintenance Jobs and Little Helpers](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/little-helpers.md)

Please be aware that this project currently only offers images and support
for basic usage. Integrations are not yet part of this, but may be added as needed.
See also relevant docs within Dataverse guides and upstream projects.

#### Development usage
First, you will need to read up and get familiar with all of the above about production usage.
More details about usage for developing Dataverse below.

* [Development container images](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/images.md#development-images)
* [Prepare toolchain](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/rundev.md#prepare-toolchain)
* [Using local cluster](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/rundev.md#local-cluster)
* [Using remote cluster](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/rundev.md#remote-cluster) (not yet supported)

<small>
<details>
<summary>If you think this is weird and/or cumbersome:</summary>
As long as K8s usage is not a first class citizen for IQSS, this project should
not (or cannot) be included in Dataverse upstream.

```diff
+ We don't have to deal with upstream merge process for PRs and can move quicker.
+ We can use tools like Skaffold, Kustomization, etc only usable when living at the topmost level.
- We have to deal with `git submodules` and somewhat bloated image builds.
- We cannot use fancy Maven tools like JIB and others.
```
</details>
</small>

#### Examples

* [Quick demo with Minikube](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/minikube.md)
* [Usage with minimized k3s](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/k3s.md)
* [Deploy to an Amazon EC2 based custom K8s cluster](https://github.com/IQSS/dataverse-kubernetes/blob/master/docs/aws-kops.md)

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
