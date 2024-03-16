# Config Syncer

Config Syncer is a tool that allows you to sync your configuration files across multiple machines.

Their [documentation](https://config-syncer.com/docs/v0.14.5/welcome/).

## Deploying Config Syncer

1. Create and change directory to `infrastructure/base/config-syncer`

2. Create `namespace.yaml`

```bash
kubectl create namespace config-syncer \
  --dry-run=client \
  --output=yaml > namespace.yaml
```

3. Create `helmrepository.yaml`

```bash
flux create source helm config-syncer \
    --interval=1h \
    --url=https://charts.config-syncer.com \
    --export > helmrepository.yaml
```

4. Create `helmrelease.yaml`

```bash
flux create helmrelease config-syncer \
    --interval=1h \
    --release-name=config-syncer \
    --namespace=config-syncer \
    --target-namespace=config-syncer \
    --source=HelmRepository/config-syncer.flux-system \
    --chart=config-syncer \
    --chart-version=">=0.14.5-0" \
    --export > helmrelease.yaml
```

5. Create `kustomization.yaml`

```bash
kustomize create --autodetect
```

6. Commit your changes to Git

## Synchronize Configuration across Namespaces

Visit the their [guide](https://config-syncer.com/docs/v0.14.5/guides/config-syncer/intra-cluster/) for more information.
