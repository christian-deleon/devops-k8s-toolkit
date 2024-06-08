# Bitnami "Sealed Secrets" for Kubernetes

Sealed Secrets is a Kubernetes Custom Resource Definition Controller which allows you to store and manage Kubernetes secrets in Git repositories in an encrypted format.

If you do not wish to deploy HashiCorp Vault, this is an alternative approach for storing secrets in your cluster. However, this approach is not recommended for production environments.

Latest version of [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#kubeseal)

Sealed Secrets own [documentation](https://github.com/bitnami-labs/sealed-secrets).

## Deploying Sealed Secrets

1. Create and change directory to `infrastructure/base/sealed-secrets`

2. Create `namespace.yaml`

```bash
kubectl create namespace sealed-secrets \
  --dry-run=client \
  --output=yaml > namespace.yaml
```

3. Create `helmrepository.yaml`

```bash
flux create source helm sealed-secrets \
    --interval=1h \
    --url=https://bitnami-labs.github.io/sealed-secrets \
    --export > helmrepository.yaml
```

4. Create `helmrelease.yaml`

```bash
flux create helmrelease sealed-secrets \
    --interval=1h \
    --release-name=sealed-secrets-controller \
    --namespace=sealed-secrets \
    --target-namespace=sealed-secrets \
    --source=HelmRepository/sealed-secrets.flux-system \
    --chart=sealed-secrets \
    --chart-version=">=1.15.0-0" \
    --crds=CreateReplace \
    --export > helmrelease.yaml
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

## Creating a Sealed Secret

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
