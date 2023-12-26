# DevOps Kubernetes Demo

## Description

This repository contains a demo of a DevOps workflow using Kubernetes and GitOps.

## Table of Contents

- [DevOps Kubernetes Demo](#devops-kubernetes-demo)
  - [Description](#description)
  - [Table of Contents](#table-of-contents)
  - [Project Structure](#project-structure)
  - [Prerequisites](#prerequisites)
    - [Common Prerequisites](#common-prerequisites)
    - [Local Kubernetes Cluster](#local-kubernetes-cluster)
    - [Production Kubernetes Cluster](#production-kubernetes-cluster)
  - [HashiCorp Packer](#hashicorp-packer)
  - [HashiCorp Terraform](#hashicorp-terraform)
  - [Ansible](#ansible)
  - [Kind (Kubernetes in Docker)](#kind-kubernetes-in-docker)
    - [Building a local Kubernetes cluster](#building-a-local-kubernetes-cluster)
  - [Flux CD](#flux-cd)
    - [Using Flux CD](#using-flux-cd)
      - [Example of an `monorepo` directory structure:](#example-of-an-monorepo-directory-structure)
      - [Configuring Flux CD](#configuring-flux-cd)
  - ["Sealed Secrets" for Kubernetes](#sealed-secrets-for-kubernetes)
    - [Creating a Sealed Secret](#creating-a-sealed-secret)
    - [Creating a Sealed SSH Key](#creating-a-sealed-ssh-key)
  - [Backup and Restore with Velero](#backup-and-restore-with-velero)

## Project Structure

```bash
├── apps
│   ├── base
│   │   └── nginx
│   │       ├── deployment.yaml
│   │       ├── kustomization.yaml
│   │       └── namespace.yaml
│   └── development
│       └── kustomization.yaml
├── clusters
│   └── development
│       ├── apps.yaml
│       ├── flux-system
│       │   ├── gotk-components.yaml
│       │   ├── gotk-sync.yaml
│       │   └── kustomization.yaml
│       └── infrastructure.yaml
├── iac
│   └── vsphere-dev
│       ├── ansible
│       │   ├── ansible.cfg
│       │   ├── collections
│       │   │   └── christian_deleon
│       │   │       └── kubernetes
│       │   ├── deploy-rke2.yml
│       │   ├── hosts
│       │   │   ├── group_vars
│       │   │   │   └── all.yml
│       │   │   └── vmware.yml
│       │   └── requirements.yml
│       ├── packer
│       │   ├── alma-linux-8
│       │   └── variables.pkrvars.hcl
│       └── terraform
│           ├── main.tf
│           └── variables.tf
├── infrastructure
│   ├── base
│   │   └── sealed-secrets
│   │       ├── helmrelease.yaml
│   │       ├── helmrepository.yaml
│   │       └── kustomization.yaml
│   └── development
│       └── kustomization.yaml
├── README.md
└── scripts
    └── flux-development-bootstrap.sh
```

## Prerequisites

You can choose to build a local Kubernetes cluster using `kind` or building a production ready cluster using `Packer`, `Terraform`, and `Ansible`.

### Common Prerequisites

- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/)
- [Flux](https://fluxcd.io/flux/installation/)
- [Velero](https://velero.io/docs/v1.3.0/basic-install/#install-the-cli)

### Local Kubernetes Cluster

- [Docker](https://docs.docker.com/engine/install/)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-with-a-package-manager)

### Production Kubernetes Cluster

- [Packer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip)

## HashiCorp Packer

HashiCorp Packer is an open-source tool for creating identical machine images for multiple platforms from a single source configuration. Packer is lightweight, runs on every major operating system, and is highly performant, creating machine images for multiple platforms in parallel.

TODO: Add Packer instructions

## HashiCorp Terraform

HashiCorp Terraform is an open-source infrastructure as code (IaC) software tool that enables you to safely and predictably create, change, and improve infrastructure. It's part of a broader suite of tools from HashiCorp designed for DevOps and cloud infrastructure management.

TODO: Add Terraform instructions

## Ansible

Ansible is an open-source software provisioning, configuration management, and application-deployment tool enabling infrastructure as code. It runs on many Unix-like systems, and can configure both Unix-like systems as well as Microsoft Windows.

TODO: Add Ansible instructions

## Kind (Kubernetes in Docker)

Kind is a tool for running local Kubernetes clusters using Docker container “nodes”. kind was primarily designed for testing Kubernetes itself, but may be used for local development or CI.

### Building a local Kubernetes cluster

1. Create a Kubernetes cluster using `kind`

```bash
kind create cluster --name devops-demo
```

2. Test the cluster

```bash
kubectl cluster-info --context kind-devops-demo
```

## Flux CD

Flux is a tool that automatically ensures that the state of a cluster matches the config in git. It uses an operator in the cluster to trigger deployments inside Kubernetes, which means you don't need a separate CD tool. It monitors all relevant image repositories, detects new images, triggers deployments and updates the desired running configuration based on that (and a configurable policy).

### Using Flux CD

#### Example of an `monorepo` directory structure:

```bash
├── apps
│   ├── base
│   ├── production
│   └── development
├── infrastructure
│   ├── base
│   ├── production
│   └── development
└── clusters
    ├── production
    └── development
```

#### Configuring Flux CD

1. Change directory to `clusters/development`

2. Create `infrastructure.yaml`

```bash
flux create kustomization infrastructure \
    --source=GitRepository/flux-system \
    --path="./infrastructure/development" \
    --prune=true \
    --interval=1m \
    --export > infrastructure.yaml
```

3. Create `apps.yaml` which depends on infrastructure

```bash
flux create kustomization apps \
    --source=GitRepository/flux-system \
    --path="./apps/development" \
    --prune=true \
    --interval=1m \
    --depends-on=infrastructure \
    --export > apps.yaml
```

4. Change directory to `apps/development`

5. Create `kustomization.yaml`

```bash
kustomize create
```

6. Repeat step 5 in `infrastructure/development`

## "Sealed Secrets" for Kubernetes

Sealed Secrets is a Kubernetes Custom Resource Definition Controller which allows you to store and manage Kubernetes secrets in Git repositories in an encrypted format.

1. Change directory to `infrastructure/base/sealed-secrets`

2. Create `helmrepository.yaml`

```bash
flux create source helm sealed-secrets \
    --interval=1h \
    --url=https://bitnami-labs.github.io/sealed-secrets \
    --export > helmrepository.yaml
```

3. Create `helmrelease.yaml`

```bash
flux create helmrelease sealed-secrets \
    --interval=1h \
    --release-name=sealed-secrets-controller \
    --target-namespace=sealed-secrets \
    --source=HelmRepository/sealed-secrets \
    --chart=sealed-secrets \
    --chart-version=">=1.15.0-0" \
    --crds=CreateReplace \
    --export > helmrelease.yaml
```

4. Create `namespace.yaml`

```bash
kubectl create namespace sealed-secrets \
  --dry-run=client \
  --output=yaml > namespace.yaml
```

5. Create `kustomization.yaml`

```bash
kustomize create --autodetect
```

6. Update `infrastructure/development/kustomization.yaml` to include the `sealed-secrets` kustomization. It should look like this:

```bash
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../base/sealed-secrets
```

7. Commit your changes to Git

8. If not using `kind`, port forward the sealed-secrets controller

```bash
kubectl port-forward -n sealed-secrets svc/sealed-secrets-controller 8080:8080
```

9. Fetch the public key

```bash
kubeseal --fetch-cert \
    --controller-name=sealed-secrets-controller \
    --controller-namespace=sealed-secrets
```

### Creating a Sealed Secret

1. Create a secret

```bash
echo -n mypassword | kubectl create secret generic postgres-password -n postgres --dry-run=client --from-file=password=/dev/stdin -o yaml > postgres-password-secret.yaml
```

3. If not using `kind`, port forward the sealed-secrets controller

```bash
kubectl port-forward -n sealed-secrets svc/sealed-secrets-controller 8080:8080
```

4. Seal the secret

```bash
kubeseal --format=yaml \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=sealed-secrets \
  < postgres-password-secret.yaml > postgres-password-sealed.yaml
```

5. Delete the unsealed secret

6. Or instead of steps 1-3, you can do this:

```bash
echo -n mypassword | kubectl create secret generic postgres-password -n postgres --dry-run=client --from-file=password=/dev/stdin -o yaml | \
  kubeseal --format=yaml \
    --controller-name=sealed-secrets-controller \
    --controller-namespace=sealed-secrets \
    > postgres-password-sealed.yaml
```

7. Commit the sealed secret to Git

### Creating a Sealed SSH Key

1. Obtain the SSH Fingerprint of Your Git Server

```bash
ssh-keyscan gitlab.robochris.net
```

This command will output several lines. You'll typically use the one starting with gitlab.robochris.net ssh-rsa.

2. Create a Known Hosts File

```bash
vim known_hosts
```

3. Create a k8s secret called `flux-git-auth` and reference your known_hosts file

```bash
kubectl create secret generic flux-git-auth \
    --from-file=identity=/home/$USER/.ssh/id_rsa \
    --from-file=known_hosts=./known_hosts \
    --dry-run=client \
    -o yaml > flux-git-auth-secret.yaml
```

4. Seal the k8s secret with kubeseal

```bash
kubeseal --controller-name=sealed-secrets-controller \
  --controller-namespace=sealed-secrets \
  --format=yaml < flux-git-auth-secret.yaml > flux-git-auth-sealed.yaml
```

5. Modify the sealed secret to add the `namespace-wide` annotation. It should look like this:

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  creationTimestamp: null
  name: flux-git-auth
  # Do not specify namespace here
  annotations:
    sealedsecrets.bitnami.com/namespace-wide: "true"
spec:
  encryptedData:
    identity: ...
    known_hosts: ...
  template:
    metadata:
      name: flux-git-auth
      # Do not specify namespace here
```

6. Create a Flux GitRepository and reference the secret `flux-git-auth`

```bash
flux create source git postgres \
    --url=ssh://git@gitlab.robochris.net/my-group/my-project.git \
    --branch=main \
    --secret-ref=flux-git-auth \
    --export > gitrepository.yaml
```

## Backup and Restore with Velero

Velero gives you tools to back up and restore your Kubernetes cluster resources and persistent volumes. You can run Velero with a public cloud platform or on-premises.

1. Change directory to `infrastructure/base/velero`

2. Create `helmrepository.yaml`

```bash
flux create source helm vmware-tanzu --url=https://vmware-tanzu.github.io/helm-charts --interval=1h --export > helmrepository.yaml
```

3. Create `helmrelease.yaml`

```bash
flux create helmrelease velero --interval=1h --release-name=velero --target-namespace=velero --source=HelmRepository/vmware-tanzu --chart=velero --chart-version=">=5.2.0-0" --export > helmrelease.yaml
```

4. Create `velero-values-secret.yaml` using the following template:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: velero-values
  namespace: velero
stringData:
  values.yaml: |
    credentials:
      secretContents:
        cloud: |
          [default]
          aws_access_key_id=<YOUR_AWS_ACCESS_KEY_ID>
          aws_secret_access_key=<YOUR_AWS_SECRET_ACCESS_KEY>
    configuration:
      backupStorageLocation:
        - name: default
          provider: aws
          bucket: <YOUR_BUCKET_NAME>
          config:
            region: <YOUR_BUCKET_REGION>
      volumeSnapshotLocation:
        - name: default
          provider: aws
          config:
            region: <YOUR_BUCKET_REGION>
    initContainers:
      - name: velero-plugin-for-aws
        image: "velero/velero-plugin-for-aws:v1.8.0"
        volumeMounts:
          - mountPath: /target
            name: plugins
    schedules:
      hourly:
        schedule: "@every 1h"
        template:
          includedNamespaces:
            - "*"
          snapshotVolumes: false
          ttl: "168h"
```

5. Seal the secret

```bash
kubeseal --format=yaml \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=sealed-secrets \
  < velero-values-secret.yaml > velero-values-sealed.yaml
```

6. Create `kustomization.yaml`

```bash
kustomize create --autodetect
```

7. Commit your changes to Git
