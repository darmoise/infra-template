# Dev deployment with Helmfile

Dev stack:

- Traefik from external `traefik/traefik` chart
- Postgres from local chart `helm/postgres`
- account-api from local chart `helm/account-api`

Secrets are applied before Helmfile via Ansible Vault.

## Image tag

Dev also uses immutable image tags. Do not deploy `latest`.

```bash
export IMAGE_TAG=0.0.19-snapshot-e2bdbe585d9b
```

`environments/dev/account-api.image.values.yaml.gotmpl` injects `IMAGE_TAG` and fails if it is missing.

## Apply secrets

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml ./scripts/apply-secrets.sh dev
```

## Diff

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml IMAGE_TAG=$IMAGE_TAG ./scripts/diff-dev.sh
```

## Apply

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml IMAGE_TAG=$IMAGE_TAG ./scripts/deploy-dev.sh
```

## Selective apply

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml IMAGE_TAG=$IMAGE_TAG helmfile -f helmfile.dev.yaml -l component=ingress apply
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml IMAGE_TAG=$IMAGE_TAG helmfile -f helmfile.dev.yaml -l component=database apply
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml IMAGE_TAG=$IMAGE_TAG helmfile -f helmfile.dev.yaml -l app=account-api apply
```

## Verify

```bash
sudo kubectl -n traefik get pods,svc
sudo kubectl -n easychat-dev get pods,svc,ingress
curl http://dev.darmoise.example.com/actuator/health
```
