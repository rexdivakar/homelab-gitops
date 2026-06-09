# Headlamp

Headlamp provides a Kubernetes web UI for the homelab cluster.

It is exposed only through private Tailscale Ingress:

```text
https://headlamp.laperm-dragon.ts.net
```

## Security

This deployment enables `unsafeUseServiceAccountToken` so the UI works directly from the tailnet URL without committing credentials. The chart service account is bound to `cluster-admin`, so anyone with access to the Headlamp Tailscale URL has administrative access to the cluster.

Keep the service private to the tailnet. Do not expose it publicly.
