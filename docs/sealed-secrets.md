# Bitnami "Sealed Secrets" for Kubernetes

Sealed Secrets is a Kubernetes Custom Resource Definition Controller which allows you to store and manage Kubernetes secrets in Git repositories in an encrypted format.

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

## Backup and Restore with Velero

Velero gives you tools to back up and restore your Kubernetes cluster resources and persistent volumes. You can run Velero with a public cloud platform or on-premises.

1. Change directory to `infrastructure/base/velero`

2. Create `helmrepository.yaml`

```bash
flux create source helm vmware-tanzu --url=https://vmware-tanzu.github.io/helm-charts --interval=1h --export > helmrepository.yaml
```

3. Create `helmrelease.yaml`

```bash
flux create helmrelease velero \
  --interval=1h \
  --release-name=velero \
  --namespace=velero \
  --target-namespace=velero \
  --source=HelmRepository/vmware-tanzu.flux-system \
  --chart=velero \
  --chart-version=">=5.2.0-0" \
  --export > helmrelease.yaml
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