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

Replace every `https://github.com/YOUR_GITHUB_USER/homelab-gitops.git` placeholder with the real GitHub repository URL before applying the Argo CD Applications.

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

Argo CD remains available privately through Tailscale at:

```text
https://argocd.laperm-dragon.ts.net
```

## Security Notes

- Do not commit Kubernetes Secrets.
- Do not commit the Tailscale OAuth client secret.
- Do not commit kubeconfig files.
- Do not commit the Argo CD admin password.
- Keep public exposure disabled; use Tailscale Ingress for private HTTPS access.
