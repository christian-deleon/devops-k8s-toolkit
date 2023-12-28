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

6. Exit the Vault pod

```bash
exit
```

## Secrets Engines

You can find all the different secrets engines in HashiCorp's own [docs](https://developer.hashicorp.com/vault/docs/secrets). But here are some common examples.

## Vault "Key/Value" Secrets Engine

### Enabling the "Key/Value" Secrets Engine

1. Follow the steps in [Enabling the Kubernetes Authentication Method](#enabling-the-kubernetes-authentication-method) section

2. Connect to Vault with [Connecting to Vault](#connecting-to-vault) section

3. Login to Vault

```bash
vault login <ROOT_TOKEN>
```

4. Enable the secrets engine

With kv-v2 (recommended)

```bash
vault secrets enable -path=secret kv-v2
```

With kv-v1

```bash
vault secrets enable -path=secret kv
```

### Creating a Secret

1. Create a Vault Role for your namespace

```bash
vault write auth/kubernetes/role/postgres \
  bound_service_account_names=vault-auth \
  bound_service_account_namespaces=postgres \
  policies=postgres \
  ttl=1h
```

2. Create a policy

With kv-v2 (recommended)

```bash
vault policy write postgres - <<EOF
path "secret/data/postgres/*" {
  capabilities = ["read"]
}
EOF
```

With kv-v1

```bash
vault policy write postgres - <<EOF
path "secret/postgres/*" {
  capabilities = ["read"]
}
EOF
```

3. Create a Vault Secret

With kv-v2 (recommended)

```bash
vault kv put secret/data/postgres/cred username="postgres" password="postgres"
```

With kv-v1

```bash
vault kv put secret/postgres/cred username="postgres" password="postgres"
```

4. Create a Kubernetes service account

```bash
kubectl create serviceaccount vault-auth -n postgres
```
