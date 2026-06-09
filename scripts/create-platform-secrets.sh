#!/usr/bin/env bash
set -euo pipefail

rand_b64() {
  openssl rand -base64 "$1" | tr -d '\n'
}

rand_hex() {
  openssl rand -hex "$1" | tr -d '\n'
}

kubectl create namespace keycloak --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace langfuse --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic keycloak-admin \
  -n keycloak \
  --from-literal=admin-password="$(rand_b64 24)" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic keycloak-postgresql \
  -n keycloak \
  --from-literal=postgres-password="$(rand_b64 24)" \
  --from-literal=password="$(rand_b64 24)" \
  --from-literal=replication-password="$(rand_b64 24)" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic langfuse-secrets \
  -n langfuse \
  --from-literal=nextauth-secret="$(rand_b64 32)" \
  --from-literal=salt="$(rand_b64 32)" \
  --from-literal=encryption-key="$(rand_hex 32)" \
  --from-literal=keycloak-client-secret="replace-after-creating-keycloak-client" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic langfuse-postgresql \
  -n langfuse \
  --from-literal=password="$(rand_b64 24)" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic langfuse-redis \
  -n langfuse \
  --from-literal=password="$(rand_b64 24)" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic langfuse-clickhouse \
  -n langfuse \
  --from-literal=password="$(rand_hex 24)" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic langfuse-minio \
  -n langfuse \
  --from-literal=root-user="langfuse" \
  --from-literal=root-password="$(rand_b64 24)" \
  --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF'
Platform secrets created in-cluster.

Next:
1. Sync keycloak.
2. Create a Keycloak realm named homelab.
3. Create a Langfuse OIDC client named langfuse.
4. Replace langfuse-secrets keycloak-client-secret with the real client secret.
EOF
