# Using k3s as deployment target

*k3s* is a very small and simple Kubernetes distribution, targeted at
edge cases like tiny microservices, Continious Integration etc. For more
information, see https://k3s.io Compared to *minikube*, *k3s* is even smaller
and more lightweight.

You can run *k3s* on hardware, a virtual machine or within a Docker container.
For usage with Docker a handy wrapper is available as [*k3d*](https://github.com/rancher/k3d).

## Deploying Dataverse to *k3s* for local development or demo purposes

### Setup K3s

First, setup a single node *k3s* cluster. Pick your favorite poison. Once you
have your cluster up and running, continue.

As *k3s* removed all "in-tree" storage classes, you will need to provide
one on your own. For simple purposes like demos or development, local storage
is sufficient. Simply add a [rancher local provisioner](https://github.com/rancher/local-path-provisioner):

```
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
```

### Let's get ready to Dataverse...

Please be aware that this demo script is using [Kustomize](https://kustomize.io)
to re-use the provided descriptors but suited for usage with *k3s*.
Please ensure to either install the binary or even better: have *kubectl* v1.14
or later installed.

Now start to deploy Dataverse plus any necessary services and bootstrap via Kustomize:
```
kubectl apply -k docs/k3s-demo
```

When bootstrapping finished (see `kubectl get job,pod` and logs), simply do a
port forwarding to access Dataverse:
```
kubectl port-forward service/dataverse 8080
```

Now you may point your favorite browser to http://localhost:8080 and enjoy
your freshly backed Dataverse demo.
