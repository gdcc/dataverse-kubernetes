# Using k3s as deployment target

*k3s* is a very small and simple Kubernetes distribution, targeted at
edge cases like tiny microservices, Continious Integration etc. For more
information, see https://k3s.io Compared to *minikube*, *k3s* is even smaller
and more lightweight.

You can run *k3s* on hardware, a virtual machine or within a Docker container.
For usage with Docker a handy wrapper is available as [*k3d*](https://github.com/rancher/k3d).

## The k3s persona: Deploying Dataverse to *k3s* for local development or demo purposes

### Setup K3s first

First, setup a single node *k3s* cluster. Pick your poison. Once you
have your cluster up and running, continue.

As *k3s* removed all "in-tree" storage classes, you will need to provide
one on your own. For simple purposes like demos or development, local storage
is sufficient. The *k3s* persona will add a [local provisioner](https://github.com/rancher/local-path-provisioner)
by default.

For a very quick shot, you can use [Docker](https://docker.com) with [k3d](https://github.com/rancher/k3d).
Remember you need to expose the `Ingress` port:
```
k3d create --publish 8080:80 --wait 0
export KUBECONFIG="$(k3d get-kubeconfig --name='k3s-default')"
```

### Let's get ready to Dataverse...

Please be aware that the *k3s* persona is using [Kustomize](https://kustomize.io)
to re-use the provided descriptors but suited for usage with *k3s*.
Please ensure to either install the binary or even better: have *kubectl* v1.14
or later installed.

Now start to deploy Dataverse plus any necessary services and bootstrap via Kustomize:
```
kubectl apply -k personas/k3s
```

When bootstrapping job finished (see `kubectl get job,pod` and logs), you can
"just access" Dataverse. *k3s* persona adds an `Ingress` route from
your host to the service: point your favorite browser to http://localhost:8080
and enjoy your freshly backed Dataverse demo.

Default login for this demo is `dataverseAdmin:admin1`. [See all secrets documentation](secrets.md).

#### A word on deployment times
On a 3 year old laptop with 16 GB RAM, SSD, a Core i5-6300U and a fairly fast
internet connection for image pulling it takes about 3 to 4 minutes from zero
to hero, not including any installation time for Docker, k3d, k3s or kubectl.
