#!/usr/bin/env bash
set -euo pipefail

echo "Checking Kubernetes connectivity..."
kubectl version
kubectl get nodes -o wide

echo
echo "Argo CD applications:"
if command -v argocd >/dev/null 2>&1; then
  argocd app list
else
  kubectl get applications -n argocd
fi

echo
echo "Longhorn namespace:"
kubectl get pods -n longhorn-system || true

echo
echo "Storage classes:"
kubectl get storageclass || true

cat <<'EOF'

Debian 12 Longhorn prerequisites to run on the Kubernetes node:
  sudo apt install -y open-iscsi nfs-common
  sudo systemctl enable --now iscsid
EOF
