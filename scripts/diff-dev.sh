#!/usr/bin/env bash
set -euo pipefail

: "${IMAGE_TAG:?Set IMAGE_TAG to immutable image tag, e.g. IMAGE_TAG=0.0.19-snapshot-e2bdbe585d9b}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"

helmfile -f helmfile.dev.yaml repos
IMAGE_TAG="$IMAGE_TAG" helmfile -f helmfile.dev.yaml diff
