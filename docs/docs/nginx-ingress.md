# NGINX Ingress Controller

NGINX Ingress Controller is an Ingress controller that manages external access to HTTP services in a Kubernetes cluster using NGINX.

## Deploying the NGINX Ingress Controller

1. Create and change directory to `infrastructure/base/nginx-ingress`

2. Create `namespace.yaml`

```bash
kubectl create namespace ingress-nginx \
  --dry-run=client \
  --output=yaml > namespace.yaml
```

3. Create `helmrepository.yaml`

```bash
flux create source helm ingress-nginx \
    --interval=1h \
    --url=https://kubernetes.github.io/ingress-nginx \
    --export > helmrepository.yaml
```

4. Create `helmrelease.yaml`

```bash
flux create helmrelease ingress-nginx \
    --interval=1h \
    --release-name=ingress-nginx \
    --namespace=ingress-nginx \
    --target-namespace=ingress-nginx \
    --source=HelmRepository/ingress-nginx.flux-system \
    --chart=ingress-nginx \
    --chart-version=">=4.9.0" \
    --export > helmrelease.yaml
```

5. Create `kustomization.yaml`

```bash
kustomize create --autodetect
```

6. Commit your changes to Git
