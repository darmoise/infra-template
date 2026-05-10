#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:?Usage: scripts/apply-secrets.sh dev|stage}"

case "$ENVIRONMENT" in
  dev|stage) ;;
  *) echo "ERROR: environment must be dev or stage" >&2; exit 1 ;;
esac

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"

required_bins=(kubectl ansible-playbook)
for bin in "${required_bins[@]}"; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "ERROR: required binary not found: $bin" >&2
    exit 1
  fi
done

VAULT_ARGS=()
if [[ -n "${ANSIBLE_VAULT_PASSWORD_FILE:-}" ]]; then
  VAULT_ARGS=(--vault-password-file "$ANSIBLE_VAULT_PASSWORD_FILE")
else
  VAULT_ARGS=(--ask-vault-pass)
fi

ansible-playbook \
  -i "ansible/inventories/${ENVIRONMENT}/hosts.ini" \
  ansible/playbooks/apply-secrets.yml \
  -e "env=${ENVIRONMENT}" \
  "${VAULT_ARGS[@]}"
