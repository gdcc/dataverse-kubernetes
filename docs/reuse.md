# Options how to use the Kubernetes descriptors

In most cases, the descriptors provided in this repo will not fit your requirements.
Kubernetes is coming in different flavors and applications needs always some customization
to meet your needs.

Everything has been designed carefully to be as pluggable as possible to avoid
any lock-in. If you think something is a blocker for your use-case, please get
in touch. Too many options and possibilities to foresee them all...

Back to topic: you have some options here, relying less or more on the provided container
images and Kubernetes descriptors:

1. Just use the images from Docker Hub.
   Obviously you could [build them yourself](images.md).
   You provide your own Kubernetes tooling.
2. Copy this project to a directory and use symlinks to parts you want to
   use, while adding descriptors you need changed.
   Might work for small cases, where no modification of the deployment is needed.
3. Same as 2., but provide patches and use them via `kubectl patch`.
   Up to you if you like it...
4. Use [Kustomize](https://kustomize.io/), nowadays available in `kubectl` >1.14.
   This is used for some of the demos, too. Really easy.
5. Go big and provide a [Helm chart](https://helm.sh/) or [Operator](https://coreos.com/operators/).
   Please open an issue and a pull request, as this is also interesting for others.

Feel free to open issues in case of questions or suggestions.
