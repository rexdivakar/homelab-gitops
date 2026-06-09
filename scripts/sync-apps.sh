#!/usr/bin/env bash
set -euo pipefail

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
  fi
}

require_cmd kubectl
require_cmd argocd

echo "Syncing homelab-root..."
argocd app sync homelab-root --prune --timeout 600
argocd app wait homelab-root --health --sync --timeout 600

echo "Syncing longhorn..."
if kubectl get storageclass longhorn >/dev/null 2>&1; then
  argocd app sync longhorn --prune --timeout 900
else
  "$(dirname "$0")/bootstrap-longhorn.sh"
fi

echo "Waiting for Longhorn storageClass..."
kubectl wait --for=jsonpath='{.metadata.name}'=longhorn storageclass/longhorn --timeout=300s

echo "Syncing monitoring..."
argocd app sync monitoring --prune --timeout 900
argocd app wait monitoring --health --sync --timeout 900
