# Stage deploy with Helmfile

Stage is a separate Kubernetes namespace and app/database stack.

## Resources

```text
namespace: easychat-stage
host: stage.darmoise.github.io
postgres release: postgres
account-api release: account-api
```

Traefik is cluster-level infrastructure and is not installed again for stage.

## Secrets

Secrets are applied before Helmfile via Ansible Vault.

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml ./scripts/apply-secrets.sh stage
```

`POSTGRES_PASSWORD` and `SPRING_DATASOURCE_PASSWORD` must match.

## Image tag

Stage must deploy an immutable image tag, not `latest`.

```bash
export IMAGE_TAG=0.0.19-snapshot-e2bdbe585d9b
```

`environments/stage/account-api.image.values.yaml.gotmpl` injects `IMAGE_TAG` and fails if it is missing.

## Diff

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml IMAGE_TAG=$IMAGE_TAG ./scripts/diff-stage.sh
```

## Apply

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml IMAGE_TAG=$IMAGE_TAG ./scripts/deploy-stage.sh
```

## Check

```bash
sudo kubectl -n easychat-stage get pods,svc,ingress
sudo kubectl -n easychat-stage rollout status statefulset/postgres
sudo kubectl -n easychat-stage rollout status deployment/account-api
curl http://stage.darmoise.github.io/actuator/health
```

## Notes

Ingress path is `/`, not `/api`, because Spring Boot currently does not know the `/api` prefix.
Later this can be changed with Traefik StripPrefix middleware or Spring `server.servlet.context-path`.
