# Secrets with Ansible Vault

This repo does not commit raw Kubernetes Secret manifests.

Source of truth for secret values:

```text
ansible/group_vars/dev/vault.yml
ansible/group_vars/stage/vault.yml
```

These files must be encrypted with Ansible Vault before commit.

## Create encrypted vault files

```bash
cp ansible/group_vars/dev/vault.template.yml ansible/group_vars/dev/vault.yml
cp ansible/group_vars/stage/vault.template.yml ansible/group_vars/stage/vault.yml

ansible-vault encrypt ansible/group_vars/dev/vault.yml
ansible-vault encrypt ansible/group_vars/stage/vault.yml
```

Edit values:

```bash
ansible-vault edit ansible/group_vars/dev/vault.yml
ansible-vault edit ansible/group_vars/stage/vault.yml
```

`postgres_password` must equal `spring_datasource_password` unless the database user password was changed manually inside Postgres.

## Apply secrets locally

Dev:

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
ansible-playbook \
  -i ansible/inventories/dev/hosts.ini \
  ansible/playbooks/apply-secrets.yml \
  -e env=dev \
  --ask-vault-pass
```

Stage:

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
ansible-playbook \
  -i ansible/inventories/stage/hosts.ini \
  ansible/playbooks/apply-secrets.yml \
  -e env=stage \
  --ask-vault-pass
```

Or use wrapper:

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml ./scripts/apply-secrets.sh dev
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml ./scripts/apply-secrets.sh stage
```

## Jenkins

Store the vault password in Jenkins Credentials:

```text
Kind: Secret file
ID: ansible-vault-password
```

Pipeline usage:

```bash
ansible-playbook \
  -i ansible/inventories/stage/hosts.ini \
  ansible/playbooks/apply-secrets.yml \
  -e env=stage \
  --vault-password-file "$ANSIBLE_VAULT_PASSWORD_FILE"
```

## What the playbook manages

For `dev` it manages namespace `easychat-dev`.
For `stage` it manages namespace `easychat-stage`.

It creates/updates:

```text
ghcr-credentials
postgres-secret
account-api-secret
```

It intentionally does not deploy the app. Helmfile deploys the app.

## Secret rotation note

Changing `postgres-secret.POSTGRES_PASSWORD` does not change the password inside an already initialized Postgres PVC.

For dev/stage either:

```bash
kubectl -n easychat-stage delete pvc postgres-data-postgres-0
```

or run SQL:

```sql
ALTER USER username WITH PASSWORD 'new-password';
```

Then restart the app:

```bash
kubectl -n easychat-stage rollout restart deployment/account-api
```
