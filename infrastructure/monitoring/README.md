# Monitoring

This folder installs `kube-prometheus-stack`, which includes Prometheus Operator, Prometheus, Alertmanager, kube-state-metrics, node-exporter, and Grafana.

Homelab defaults:

- Prometheus retention is `7d`.
- Prometheus uses a Longhorn PVC.
- Grafana uses a Longhorn PVC.
- Grafana service remains `ClusterIP`.
- Grafana is exposed privately through Tailscale Ingress at `https://grafana.laperm-dragon.ts.net`.
- Alertmanager is disabled by default to reduce resource use until alert routing is configured.

## Dependency

Sync monitoring only after Longhorn is healthy and the `longhorn` StorageClass exists:

```sh
kubectl get storageclass longhorn
```

The `homelab` AppProject allows `kube-system` because kube-prometheus-stack renders scrape resources there for control-plane components.

## Verify

```sh
kubectl get pods -n monitoring
kubectl get pvc -n monitoring
kubectl get ingress -n monitoring
```

## Grafana

Apply the Tailscale Ingress after the monitoring chart has created the Grafana service:

```sh
kubectl apply -f infrastructure/monitoring/grafana-tailscale-ingress.yaml
```
