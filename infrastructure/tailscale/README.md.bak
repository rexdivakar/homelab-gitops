# Tailscale Ingress

The Tailscale Kubernetes Operator is already installed in the `tailscale` namespace.

Current working setup:

- Argo CD is exposed privately at `https://argocd.laperm-dragon.ts.net`.
- Use Kubernetes `Ingress` with `ingressClassName: tailscale` when you want Tailscale-managed HTTPS.
- Do not use public ingress controllers for this homelab repo.
- `LoadBalancer` services through Tailscale forward TCP but do not terminate HTTPS.
- Tailscale Ingress terminates HTTPS and forwards plain HTTP to the backend service.
- Argo CD must run with `server.insecure=true` because Tailscale Ingress handles HTTPS.

## Useful Commands

```sh
kubectl get pods -n tailscale
kubectl get ingress -A
kubectl logs -n tailscale <tailscale-proxy-pod>
```

## URL Pattern

An Ingress host named `example-app` is exposed at:

```text
https://example-app.laperm-dragon.ts.net
```
