# easychat-infra

Production-like Kubernetes infra for EasyChat.

## Stack

```text
k3s
Helm / Helmfile
Traefik ingress
Postgres StatefulSet
account-api Deployment
Ansible Vault for secret delivery
Jenkins for orchestration
```

## Secrets

Raw Kubernetes secret manifests are not committed.

Use encrypted Ansible Vault files:

```text
ansible/group_vars/dev/vault.yml
ansible/group_vars/stage/vault.yml
```

See: `docs/ansible-vault-secrets.md`.

## Dev

Deploy dev with an immutable image tag:

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
IMAGE_TAG=0.0.19-snapshot-e2bdbe585d9b \
./scripts/deploy-dev.sh
```

Diff:

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
IMAGE_TAG=0.0.19-snapshot-e2bdbe585d9b \
./scripts/diff-dev.sh
```

Details: `docs/helmfile-dev.md`.

## Stage

Promote the exact image tag that was built by CI:

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
IMAGE_TAG=0.0.19-snapshot-e2bdbe585d9b \
./scripts/deploy-stage.sh
```

Diff:

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
IMAGE_TAG=0.0.19-snapshot-e2bdbe585d9b \
./scripts/diff-stage.sh
```

Details: `docs/helmfile-stage.md`.
