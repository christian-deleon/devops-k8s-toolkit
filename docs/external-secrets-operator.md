# External Secrets Operator

External Secrets Operator is a Kubernetes operator that allows you to use external secret management systems (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager, HashiCorp Vault, and more) to securely add secrets in your Kubernetes applications.

External Secrets Operator [documentation](https://external-secrets.io/latest/).

## Deploying External Secrets Operator

1. Create and change directory to `infrastructure/base/external-secrets`

2. Create `namespace.yaml`

```bash
kubectl create namespace external-secrets \
  --dry-run=client \
  --output=yaml > namespace.yaml
```

3. Create `helmrepository.yaml`

```bash
flux create source helm external-secrets \
    --interval=1h \
    --url=https://charts.external-secrets.io \
    --export > helmrepository.yaml
```

4. Create `helmrelease.yaml`

```bash
flux create helmrelease external-secrets \
    --interval=1h \
    --release-name=external-secrets \
    --namespace=external-secrets \
    --target-namespace=external-secrets \
    --source=HelmRepository/external-secrets.flux-system \
    --chart=external-secrets \
    --chart-version=">=0.9.13" \
    --export > helmrelease.yaml
```

5. Create `kustomization.yaml`

```bash
kustomize create --autodetect
```

6. Update `infrastructure/development/kustomization.yaml` to include the `external-secrets` kustomization. It should look like this:

```bash
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../base/external-secrets
```

7. Commit your changes to Git
