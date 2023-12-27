# HashiCorp Vault

HashiCorp Vault is a secrets management tool that helps to provide secure, automated access to sensitive data. Vault handles leasing, key revocation, key rolling, auditing, and provides secrets as a service through a unified API.

Latest version of [Vault](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-install).

Vaults own [documentation](https://developer.hashicorp.com/vault/docs).

## Deploying Vault

1. Create and change directory to `infrastructure/base/vault`

2. Create `namespace.yaml`

```bash
kubectl create namespace vault \
  --dry-run=client \
  --output=yaml > namespace.yaml
```

3. Create `helmrepository.yaml`

```bash
flux create source helm hashicorp \
    --interval=1h \
    --url=https://helm.releases.hashicorp.com \
    --export > helmrepository.yaml
```

4. Create `helmrelease.yaml`

```bash
flux create helmrelease vault \
    --interval=1h \
    --release-name=vault \
    --namespace=vault \
    --target-namespace=vault \
    --source=HelmRepository/hashicorp.flux-system \
    --chart=vault \
    --chart-version=">=0.27.0-0" \
    --export > helmrelease.yaml
```

5. Create `kustomization.yaml`

```bash
kustomize create --autodetect
```

6. Commit your changes to Git
   
## Connecting to Vault

1. Port forward the Vault server

```bash
kubectl port-forward -n vault svc/vault 8200:8200
```

2. Set the `VAULT_ADDR` environment variable

```bash
export VAULT_ADDR=http://localhost:8200
```

3. Check the status of Vault

```bash
vault status
```

## Initialize Vault

1. Connect to Vault with [Connecting to Vault](#connecting-to-vault) section

2. Initialize Vault

```bash
vault operator init
```

Save the `root_token` and `unseal_keys` in a safe place.

3. Unseal Vault (run 3 times) with the keys from the previous command

```bash
vault operator unseal <UNSEAL_KEY>
```

## Enabling the Kubernetes Authentication Method

1. Exec into the Vault pod

```bash
kubectl exec -it vault-0 -n vault -- sh
```

2. Login to Vault

```bash
vault login <ROOT_TOKEN>
```

3. Enable the Kubernetes authentication method

```bash
vault auth enable kubernetes
```

4. Set Variables

```bash
export K8S_HOST=https://$KUBERNETES_PORT_443_TCP_ADDR:443 \
  SA_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token) \
  K8S_CACERT_PATH=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

5. Configure the Kubernetes authentication method

```bash
vault write auth/kubernetes/config \
  kubernetes_host="$K8S_HOST" \
  token_reviewer_jwt=$SA_TOKEN \
  kubernetes_ca_cert=@$K8S_CACERT_PATH
```

6. Create Vault Role

```bash
vault write auth/kubernetes/role/internal-app \
  policies=internal-app \
  bound_service_account_names=vault-auth \
  bound_service_account_namespaces=vault \
  ttl=24h
```

7. Create a policy

```bash
vault policy write internal-app - <<EOF
path "secret/data/internal-app/*" {
  capabilities = ["read"]
}
EOF
```

8. Exit the Vault pod

```bash
exit
```

9. Create a Kubernetes service account

```bash
kubectl create serviceaccount vault-auth -n vault
```
