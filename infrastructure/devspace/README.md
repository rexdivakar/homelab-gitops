# DevSpace

DevSpace is a client-only CLI and has no server-side component to deploy.

Install it on the workstation:

```sh
brew install devspace
```

DevSpace uses your local kubeconfig/RBAC. It does not authenticate through Keycloak unless your Kubernetes API server itself is configured for OIDC.
