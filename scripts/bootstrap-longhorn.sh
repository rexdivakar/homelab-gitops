#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${ARGOCD_LONGHORN_APP:-longhorn}"
NAMESPACE="${LONGHORN_NAMESPACE:-longhorn-system}"
HOOK_JOB="${LONGHORN_PRE_UPGRADE_JOB:-longhorn-pre-upgrade}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
  fi
}

require_cmd kubectl

echo "Checking Kubernetes connectivity..."
kubectl version

if ! command -v argocd >/dev/null 2>&1; then
  cat <<EOF
argocd CLI is not installed or not on PATH.

Fallback via Argo CD UI:
1. Open https://argocd.laperm-dragon.ts.net/applications/${APP_NAME}
2. Disable auto-sync for ${APP_NAME}.
3. Delete any stuck ${NAMESPACE}/${HOOK_JOB} Job:
   kubectl delete job -n ${NAMESPACE} ${HOOK_JOB} --ignore-not-found=true
4. Run a manual sync that skips hooks. In CLIs that support it, this is:
   argocd app sync ${APP_NAME} --skip-hooks
   With argocd v3.4.x, use selective sync excluding the hook Job:
   argocd app sync ${APP_NAME} --resource '!batch:Job:${NAMESPACE}/${HOOK_JOB}'
5. Re-enable auto-sync with prune and self-heal after Longhorn is healthy.
EOF
  exit 0
fi

sync_without_hooks() {
  if argocd app sync --help | grep -q -- "--skip-hooks"; then
    argocd app sync "${APP_NAME}" --skip-hooks --prune --timeout 900
  else
    argocd app sync "${APP_NAME}" \
      --resource "!batch:Job:${NAMESPACE}/${HOOK_JOB}" \
      --prune \
      --timeout 900
  fi
}

echo "Temporarily disabling auto-sync for ${APP_NAME}..."
kubectl patch application "${APP_NAME}" -n argocd --type merge -p '{"spec":{"syncPolicy":null}}'

echo "Deleting stuck ${NAMESPACE}/${HOOK_JOB} Job if it exists..."
kubectl delete job -n "${NAMESPACE}" "${HOOK_JOB}" --ignore-not-found=true

echo "Syncing ${APP_NAME} without hook execution for the fresh install..."
sync_without_hooks

echo "Restoring auto-sync for ${APP_NAME}..."
kubectl patch application "${APP_NAME}" -n argocd --type merge -p '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true},"syncOptions":["CreateNamespace=true","ServerSideApply=true","SkipDryRunOnMissingResource=true"]}}}'

echo "Longhorn pods:"
kubectl get pods -n "${NAMESPACE}"

echo "Storage classes:"
kubectl get storageclass
