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
docker build -t iqss/dataverse-k8s:4.16 -f docker/dataverse-k8s/glassfish/Dockerfile .
docker build -t iqss/solr-k8s:4.16 docker/solr-k8s
```
*Please remember to change the tag above as appropriate. You should be*
*using tagged images as best practice, not 'latest'.*

## Development images

*NOTE: You don't need to worry about anything related to Dataverse like compilation.*
*Image building will take care of it. So if you don't have Maven installed,*
*don't use an IDE or just want to try out sth.: you are all set. Go ahead.*

### Prepare Dataverse sources
For building images from any branch or commit of Dataverse, you need to have
it in your Docker build context. Easiest way to achieve this, after cloning the
K8s repo, run:

```
git submodule sync --recursive
git submodule update --init --recursive
```

This will checkout the upstream Dataverse `develop` branch into `./dataverse`.
If you want a feature branch, add your fork, whatever: just follow normal `git submodule`
routines. (For example, goto `./dataverse` and `git checkout` your branch.)

For more on submodules, have a look at
  - https://medium.com/@porteneuve/mastering-git-submodules-34c65e940407
  - https://chrisjean.com/git-submodules-adding-using-removing-and-updating/
  - https://gist.github.com/gitaarik/8735255
  - https://lmgtfy.com/?q=git+submodule

You can even point your IDE to this new subfolder and it will work like a champ.

### Build snappy images manually
Simply use Docker again (almost like above, but different path):
```
docker build -t iqss/dataverse-k8s:test -f docker/dataverse-k8s/glassfish-dev/Dockerfile .
```
*NOTE: currently there is no Solr development image. This is likely to change.*

### Build images automatically (with Skaffold)
Please see [development usage docs](rundev.md) for this. It will make your life
easier, I suppose.
