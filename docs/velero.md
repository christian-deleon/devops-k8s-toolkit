# VMware Tanzu Velero

Velero gives you tools to back up and restore your Kubernetes cluster resources and persistent volumes. You can run Velero with a public cloud platform or on-premises.

Latest version of [Velero](https://velero.io/docs/v1.12/basic-install/#install-the-cli)

Velero's own [documentation](https://velero.io/docs/main/)

## Deploy Velero

1. Create and Change directory to `infrastructure/base/velero`

2. Create `namespace.yaml`

```bash
kubectl create namespace velero
```

3. Create `helmrepository.yaml`

```bash
flux create source helm vmware-tanzu \
    --url=https://vmware-tanzu.github.io/helm-charts \
    --interval=1h \
    --export > helmrepository.yaml
```

4. Create `helmrelease.yaml`

```bash
flux create helmrelease velero \
    --source=HelmRepository/vmware-tanzu \
    --chart=velero \
    --chart-version=">=5.2.0-0" \
    --release-name=velero \
    --target-namespace=velero \
    --interval=1h \
    --values=./values.yaml \
    --export > helmrelease.yaml
```

5. Create `kustomization.yaml`

```bash
kustomize create --autodetect
```

6. Commit your changes to Git

## Configuring AWS Backup Storage Location

1. [Create a S3 bucket](https://github.com/vmware-tanzu/velero-plugin-for-aws#create-s3-bucket)

2. [Create an IAM user](https://github.com/vmware-tanzu/velero-plugin-for-aws#set-permissions-for-velero)

3. Configure the backup storage location - [Velero Docs](https://github.com/vmware-tanzu/velero-plugin-for-aws#install-and-start-velero)

```bash
velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.8.2 \
    --bucket $BUCKET \
    --backup-location-config region=$REGION \
    --snapshot-location-config region=$REGION \
    --secret-file ./credentials-velero
```

## Create a Backup Schedule

[Velero Docs](https://velero.io/docs/v1.12/backup-reference/)

```bash
velero schedule create <SCHEDULE_NAME> \
    --schedule="@every 24h" \
    --include-namespaces <NAMESPACES> \
    --exclude-namespaces <NAMESPACES> \
    --ttl 72h0m0s
```

If you wish to backup all namespaces, you can use the `--all-namespaces` flag instead of `--include-namespaces` and `--exclude-namespaces`.

```bash
velero schedule create <SCHEDULE_NAME> \
    --schedule="@every 24h" \
    --all-namespaces \
    --ttl 72h0m0s
```
