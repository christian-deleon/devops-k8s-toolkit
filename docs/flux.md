# Flux CD

Flux is a tool that automatically ensures that the state of a cluster matches the config in git. It uses an operator in the cluster to trigger deployments inside Kubernetes, which means you don't need a separate CD tool. It monitors all relevant image repositories, detects new images, triggers deployments and updates the desired running configuration based on that (and a configurable policy).

Latest version of [Flux](https://fluxcd.io/flux/installation/#install-the-flux-cli).

Fluxs own [documentation](https://fluxcd.io/flux/).

## Example of an `monorepo` directory structure:

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

## Configuring Flux CD

1. Change directory to `clusters/development`

2. Create `infrastructure.yaml`

```bash
flux create kustomization infrastructure \
    --source=GitRepository/flux-system \
    --path="./flux/infrastructure/development" \
    --prune=true \
    --interval=1m \
    --export > infrastructure.yaml
```

3. Create `apps.yaml` which depends on infrastructure

```bash
flux create kustomization apps \
    --source=GitRepository/flux-system \
    --path="./flux/apps/development" \
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

## Adding an App from a private Git Repository

1. Change directory to `apps/base/my-app`

2. Create 'namespace.yaml' if it does not exist

```bash
kubectl create namespace my-app
```

3. Create 'gitrepository.yaml'

```bash
flux create source git my-app \
    --url=ssh://git@gitlab.robochris.net/my-group/my-app.git \
    --branch=develop \
    --secret-ref=flux-system \
    --export > gitrepository.yaml
```

4. Create 'flux-kustomization.yaml'

```bash
flux create kustomization my-app \
    --source=GitRepository/my-app.flux-system \
    --path="./k8s" \
    --prune=true \
    --interval=1m \
    --namespace=my-app-namespace \
    --export > flux-kustomization.yaml
```

Add `flux-system` in `--source=GitRepository/my-app.flux-system` if the GitRepository is in another namespace `flux-system` for this example.

1. Create 'kustomization.yaml'

```bash
kustomize create --autodetect
```

6. Commit and push changes to Git
