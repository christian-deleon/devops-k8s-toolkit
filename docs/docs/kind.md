# Kind

Kind is a tool for running local Kubernetes clusters using Docker container “nodes”. kind was primarily designed for testing Kubernetes itself, but may be used for local development or CI.

Latest version of [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-with-a-package-manager).

Kinds own [documentation](https://kind.sigs.k8s.io/).

## Building a local Kubernetes cluster

1. Create a Kubernetes cluster using `kind`

```bash
kind create cluster --name devops-demo --image kindest/node:v1.26.6 --config kind.yaml
```

2. Test the cluster

```bash
kubectl cluster-info --context kind-devops-demo
```

3. Delete the cluster

```bash
kind delete cluster --name devops-demo
```
