# Monitoring

This folder installs `kube-prometheus-stack`, which includes Prometheus Operator, Prometheus, Alertmanager, kube-state-metrics, node-exporter, and Grafana.

Homelab defaults:

- Prometheus retention is `7d`.
- Prometheus uses a Longhorn PVC.
- Grafana uses a Longhorn PVC.
- Grafana service remains `ClusterIP`.
- Grafana is exposed privately through Tailscale Ingress at `https://grafana.laperm-dragon.ts.net`.
- Alertmanager is disabled by default to reduce resource use until alert routing is configured.

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
