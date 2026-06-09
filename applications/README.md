# Applications

Place future homelab application manifests or Argo CD Applications here.

Defaults for this repo:

- Keep services as `ClusterIP`.
- Use Tailscale Ingress for private HTTPS access from the tailnet.
- Do not commit Secrets, kubeconfigs, API tokens, OAuth client secrets, or passwords.
- Prefer one replica unless the application needs otherwise and the single-node cluster can support it.
