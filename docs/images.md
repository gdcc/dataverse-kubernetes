# Container images

This project provides `Dockerfile`s and scripts to include in container
images to be used for the Dataverse deployment.

1. You can use them from Docker Hub. Those are built and tested by CI on every push to `master` and tag.
2. Derive those and push your customized image to a place you like.
3. Build the genuine images yourself and push to a registry of your choice.

## Tooling

*Currently, only Docker is supported for image building.*

You might try to build with [Podman](https://podman.io) or [Buildah](https://buildah.io/), too.
This has the advantage of no need to run a Docker daemon, which might be easier
when using your custom CI.

## Production images

Simple with Docker after cloning and accessing the source folder:
```
docker build -t iqss/dataverse-k8s:4.15.1 -f docker/dataverse-k8s/glassfish/Dockerfile .
docker build -t iqss/solr-k8s:4.15.1 docker/solr-k8s
```
*Please remember to change the tag above as appropriate. You should be*
*using tagged images as best practice, not 'latest'.*

## Development images

### Prepare Dataverse sources
For building images from any branch or commit of Dataverse, you need to have
it in your Docker build context. Easiest way to achieve this, after cloning the
K8s repo, run:

```
git submodule init
```

This will checkout the upstream Dataverse `develop` branch into `./dataverse`.
