# MetalLB

MetalLB is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.

## Deploying MetalLB

1. Create and change directory to `infrastucture/base/metallb`

2. Create `namespace.yaml`

```bash
kubectl create namespace metallb-system \
    --dry-run=client \
    -o yaml > namespace.yaml
```

3. Create `helmrepository.yaml`

```bash
flux create source helm metallb \
    --url=https://metallb.github.io/metallb \
    --interval=1h \
    --export > helmrepository.yaml
```

4. Create `helmrelease.yaml`

```bash
flux create helmrelease metallb \
    --interval=1h \
    --release-name=metallb \
    --namespace=metallb-system \
    --target-namespace=metallb-system \
    --source=HelmRepository/metallb.flux-system \
    --chart=metallb \
    --chart-version=">=0.13.12-0" \
    --export > helmrelease.yaml
```

5. Create `ipaddresspool.yaml`

```bash
cat <<EOF > ipaddresspool.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  addresses:
  - "192.168.1.65-192.168.1.65"
EOF
```

Replace `addresses` with the IP address range you want to use.

6. Create `l2advertisement.yaml`

```bash
cat <<EOF > l2advertisement.yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advertisement
  namespace: metallb-system
EOF
```

5. Create `kustomization.yaml`

```bash
kustomize create --autodetect
```

6. Commit your changes to Git
