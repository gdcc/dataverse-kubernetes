# Running Dataverse development snapshots

Images on Docker Hub are meant for production usage or quick demos.
When developing Dataverse, testing a new feature not yet shipped in a release or
running integration tests you have a need to deploy all moving parts into
a (more or less) ephemeral environment.

**Be warned:** deployment times of Dataverse are a nightmare as of writing (Sept. 2019).
For any change to the codebase, you most likely will have to wait about five
to ten minutes to redeploy from compilation to reload of webpage.

This is due to a really big WAR file (which needs to be loaded into the cluster)
and being stuck on old technology in combination with a tremendous monolith.

**YOU HAVE BEEN WARNED.**

## Prepare toolchain
For efficient workflows, tools make life easier. Please install:

1. [skaffold](https://skaffold.dev/docs/getting-started/#installing-skaffold)
2. [kustomize](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md)
    * necessary as long as GoogleContainerTools/skaffold#1781 isn't resolved

When you opt for using a local cluster, add:

1. [Docker](https://docs.docker.com/install/)
2. [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
   <small>(be nice to yourself, download a release, don't compile from source)</small>

*Note: you do have `kubectl` already installed, don't you?*

## Workflow
While you can build and deploy everything manually, it will be easier to
let Skaffold take care of everything.

Running `skaffold run` or `skaffold dev` will build, tag and deploy for you.
For a deeper insight, read docs at https://skaffold.dev/docs.

As you will need to access services, be sure to add `--port-forward`.
See also [port forward docs](https://skaffold.dev/docs/how-tos/portforward).

**Before running Skaffold for the first time** be sure to have a cluster at hands.
You can check via `kubectl`. Currently only using a local cluster with `kind` is
supported by this project, see next section. PRs welcome.

### A word on waiting
Be aware that initial builds and deployments take lots of time due to cold caches.
Recurring builds and deployments will be much faster, although you will still
suffer from Glassfish WAR deployment times.

Typically, when there is no change to `pom.xml` and caches are warmed up,
* building will take ~1 minute,
* loading images into cluster ~45 secs,
* deploying to K8s ~30 secs
* and Glassfish startup + WAR deployment ~3 minutes.

<small>*How about some coffee?*</small>

### Local cluster
The easiest way to work with a local cluster is using [kind](https://kind.sigs.k8s.io/docs/user/quick-start/), which is an abbrev for "Kubernetes IN Docker".

Skaffold supports this out of the box now. Using `kind`, your context will be set
to sth. like "@kind", which triggers loading images into a local `kind` cluster
instead of pushing to remote registry.

After installing Docker and `kind`, you simply need to run:
```
kind create cluster
```
or - if your prefer a specific K8s version, e.g. `1.14.6`:
```
kind create cluster --image kindest/node:v1.14.6
```

<small><i>
Please note that `kind` might have some troubles with changing networks and
switching to a new DNS resolver. You might need to rebuild the cluster, which is
no big deal.
</i></small>

If you want to use `k3s`, `minikube`, `microk8s` or similar, please consult the
Skaffold docs, search via Google, etc.

### Remote cluster
Currently only using a [local cluster](#local-cluster) with `kind` is supported by this project.
PRs welcome. Hint: we'll need [Kaniko](https://github.com/GoogleContainerTools/kaniko)
for that, as Docker Hub must not be cluttered.

## Future ideas
- Test using [telepresence](https://www.telepresence.io/) - it might lower dev cycle time
