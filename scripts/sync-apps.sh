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

sync_and_wait() {
  local app="$1"
  local timeout="${2:-900}"

  echo "Syncing ${app}..."
  argocd app sync "${app}" --prune --timeout "${timeout}"
  argocd app wait "${app}" --health --sync --timeout "${timeout}"
}

echo "Syncing homelab-root..."
argocd app sync homelab-root --prune --timeout 600
argocd app wait homelab-root --health --sync --timeout 600

sync_and_wait cert-manager 900
sync_and_wait cloudnative-pg 900

if kubectl get storageclass longhorn >/dev/null 2>&1; then
  sync_and_wait longhorn 900
else
  "$(dirname "$0")/bootstrap-longhorn.sh"
fi

echo "Waiting for Longhorn storageClass..."
kubectl wait --for=jsonpath='{.metadata.name}'=longhorn storageclass/longhorn --timeout=300s

sync_and_wait keycloak 900
sync_and_wait vault 900
sync_and_wait monitoring 900
sync_and_wait headlamp 900
sync_and_wait langfuse 1200
sync_and_wait popeye 600
