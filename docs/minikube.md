# Quick demonstration deployment using Minikube

This how-to suggests you have a working [Minikube](https://kubernetes.io/docs/setup/minikube/)
installation at hands. If not, follow the upstream instructions to get started.

### Setup Minikube
Please provide at least 4096 MB of RAM for the Minikube VM, as Dataverse will
use **a lot** of RAM during deployment and at least 1024 MB when idle:
```
minikube start --memory=4096
minikube addon enable ingress
```
*Note:* There have been mentions of a OOM-killed API Server on Windows using VirtualBox.
When this happens, please delete and start over with 8096 MB memory.

### Deploy Dataverse Demo
Now let's create some resources with a habit of "fire'n'forget" (at least till
its ready) to create a demo:
```
kubectl apply -k personas/minikube
```

You can check the status of the containers and the bootstrapping job from
the output of `kubectl get pods,jobs` and `kubectl logs`.

### Make Dataverse reachable via browser
While you wait for the deployment to happen, you can add the `Ingress` IP address
to your `/etc/hosts`:
```
kubectl get ingress
```
Take a note of the IP address (it might take a while till it appears, try again)
and add it to `/etc/hosts`:
```
IP.of.Ingress.here dataverse.demo
```

As soon as the deployment finished, you can reach your freshly baked Dataverse
demo via your browser at http://dataverse.demo.

Default login for this demo is `dataverseAdmin:admin1`. [See all secrets documentation](secrets.md).

### A word on deployment times
On a 3 year old laptop with 16 GB RAM, SSD, a Core i5-6300U and a fairly fast
internet connection for image pulling it takes about 6 to 8 minutes from zero
to hero, not including any installation time for minikube, VirtualBox or kubectl.
