# Homelab GitOps

GitOps-ready Kubernetes configuration for an existing single-node Debian 12 homelab cluster.

Current assumptions:

- Kubernetes is already running.
- Argo CD is already installed in the `argocd` namespace.
- Tailscale Kubernetes Operator is already installed in the `tailscale` namespace.
- Argo CD is exposed privately through Tailscale Ingress at `https://argocd.laperm-dragon.ts.net`.
- Argo CD server uses `server.insecure=true` because Tailscale Ingress terminates HTTPS.
- Services stay `ClusterIP` unless explicitly exposed through Tailscale Ingress.
- No secrets, kubeconfigs, OAuth credentials, or Argo CD passwords are stored in Git.

## Repository URL Placeholder

Replace every `https://github.com/rexdivakar/homelab-gitops.git` placeholder with the real GitHub repository URL before applying the Argo CD Applications.

## Install Order

1. Create a GitHub repository.
2. Commit and push these generated files.
3. Apply the Argo CD AppProject.
4. Apply either the root app or individual apps.

```sh
kubectl apply -f bootstrap/projects/homelab-project.yaml
```

To let Argo CD manage all infrastructure folders through the App-of-Apps pattern:

```sh
kubectl apply -f bootstrap/root-app.yaml
```

For a fresh cluster, use the scripts to avoid the Longhorn first-sync hook trap and then sync monitoring after Longhorn creates the `longhorn` StorageClass:

```sh
scripts/check-cluster.sh
scripts/bootstrap-longhorn.sh
scripts/sync-apps.sh
```

Or apply individual apps manually:

```sh
kubectl apply -f infrastructure/longhorn/application.yaml
kubectl apply -f infrastructure/monitoring/application.yaml
kubectl apply -f infrastructure/tailscale/argocd-ingress.yaml
kubectl apply -f infrastructure/monitoring/grafana-tailscale-ingress.yaml
```

## Debian 12 Prerequisites For Longhorn

Run these on the Debian 12 Kubernetes node before installing Longhorn:

```sh
sudo apt update
sudo apt install -y open-iscsi nfs-common
sudo systemctl enable --now iscsid
```

Longhorn works best with three or more nodes and replicated volumes. This repo configures Longhorn for a single-node homelab with one replica, which is practical for testing and local services but does not protect against node or disk failure.

## Sync Ordering

The root app uses Argo CD sync waves so Longhorn is created before monitoring:

- `longhorn`: wave `10`
- `monitoring`: wave `20`
- Grafana Tailscale Ingress: wave `30`

Monitoring uses Longhorn-backed PVCs. Do not sync monitoring until this succeeds:

```sh
kubectl get storageclass longhorn
```

## Verify

```sh
kubectl get pods -n longhorn-system
kubectl get storageclass
kubectl get pods -n monitoring
kubectl get ingress -A
kubectl get applications -n argocd
```

Grafana will be available privately through Tailscale at:

```text
https://grafana.laperm-dragon.ts.net
```

Longhorn will be available privately through Tailscale at:

```text
https://longhorn.laperm-dragon.ts.net
```

Headlamp will be available privately through Tailscale at:

```text
https://headlamp.laperm-dragon.ts.net
```

Argo CD remains available privately through Tailscale at:

```text
https://argocd.laperm-dragon.ts.net
```

## Troubleshooting

### Longhorn `longhorn-pre-upgrade` Hook Stuck

Longhorn chart `pre-upgrade` hooks are rendered by Helm and interpreted by Argo CD as sync hooks. Argo CD hook behavior is phase-based: a failed `PreSync` hook stops the whole sync. Argo CD also documents that Helm `pre-upgrade` maps to `PreSync`, and Helm is only used to render manifests while Argo CD owns the lifecycle.

On a fresh Longhorn install, the `longhorn-pre-upgrade` Job can run before Longhorn service account/RBAC/settings CRDs are ready and then block the application with:

```text
waiting for completion of hook batch/Job/longhorn-pre-upgrade
```

Use the bootstrap script for the first install:

```sh
scripts/bootstrap-longhorn.sh
```

The script temporarily disables Longhorn auto-sync, deletes any stuck `longhorn-pre-upgrade` Job, syncs Longhorn without hook execution, restores auto-sync, and verifies pods plus StorageClasses. With Argo CD CLIs that support `--skip-hooks`, it uses that flag. With the current `argocd v3.4.x` CLI, it uses selective sync and excludes `batch:Job:longhorn-system/longhorn-pre-upgrade`; Argo CD documents that hooks do not run during selective sync.

### Longhorn Service Account Or RBAC Not Ready

Symptoms:

```text
serviceaccount longhorn-service-account not found
User system:serviceaccount:longhorn-system:longhorn-service-account cannot get resource settings.longhorn.io
```

These are first-install ordering symptoms from the pre-upgrade hook running too early. Run:

```sh
kubectl delete job -n longhorn-system longhorn-pre-upgrade --ignore-not-found=true
scripts/bootstrap-longhorn.sh
```

### Monitoring Fails Before Longhorn Exists

Monitoring uses `storageClassName: longhorn` for Prometheus and Grafana PVCs. If Longhorn is not installed yet, monitoring can remain `Missing` or `OutOfSync`.

Verify Longhorn first:

```sh
kubectl get pods -n longhorn-system
kubectl get storageclass longhorn
```

Then sync monitoring:

```sh
argocd app sync monitoring
```

`kube-prometheus-stack` also renders some control-plane scrape Services and ServiceMonitors in `kube-system`. The `homelab` AppProject allows `kube-system` for that reason.

## Security Notes

- Do not commit Kubernetes Secrets.
- Do not commit the Tailscale OAuth client secret.
- Do not commit kubeconfig files.
- Do not commit the Argo CD admin password.
- Keep public exposure disabled; use Tailscale Ingress for private HTTPS access.
