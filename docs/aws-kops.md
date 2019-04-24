# Run on custom AWS EC2 cluster

Amazon offers virtual machines as EC2 instances and a managed Kubernetes cluster
service.

This HOWTO describes how to run Dataverse on a custom K8s cluster which is
deployed by yourself and not managed by Amazon.

## Use a tool to deploy an EC2 based K8s cluster

At https://kubernetes.io/docs/setup/turnkey/aws you can find a list of tools
how to deploy a cluster to AWS. As an example, we will use [kops](https://github.com/kubernetes/kops).

Follow the [AWS instructions](https://github.com/kubernetes/kops/blob/master/docs/aws.md):
1. Install `kops` and `kubectl`. Please install kubectl v1.14 or later so kustomize is usable (see below).
2. For demo purposes, you can safely skip the DNS setup. Gossip DNS is sufficient.
3. Choose a AWS region. You will need to use it throughout the lifetime of your cluster.
  * `export KOPS_REGION=us-east-1`
4. Create a S3 bucket using the region you choosed before:
  * `aws s3api create-bucket --bucket prefix-example-com-state-store --region ${REGION}`
5. Export name (beware to use k8s.local when using Gossip DNS) and state store location:
  * `export NAME=myfirstcluster.k8s.local`
  * `export KOPS_STATE_STORE=s3://prefix-example-com-state-store`
6. Create a cluster description:
  * `kops create cluster --kubernetes-version 1.13.5 --zones "${KOPS_REGION}a" --name ${NAME}`
7. Apply and deploy:
  * `kops update cluster ${NAME} --yes`

Enjoy your cluster. "It should be ready in a few minutes" should be taken seriously.

## Deploy Dataverse application to cluster

Using kustomize, this is pretty easy and fast forward:
```
kubectl apply -k docs/aws-demo
```

This will deploy a default demo instance to your cluster. See also:
[minikube demo](minikube.md) and [k3s demo](k3s.md).
