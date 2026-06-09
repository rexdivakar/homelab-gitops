# Keycloak

Private URL:

```text
https://keycloak.laperm-dragon.ts.net
```

Secrets are intentionally not committed. Create them before syncing:

```sh
scripts/create-platform-secrets.sh
```

Use Keycloak for UI applications that support OIDC. Kubernetes operators and CLIs do not use Keycloak directly.
