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
