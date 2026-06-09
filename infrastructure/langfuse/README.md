# Langfuse

Private URL:

```text
https://langfuse.laperm-dragon.ts.net
```

Create required generated secrets before syncing:

```sh
scripts/create-platform-secrets.sh
```

The values file points Langfuse at the Keycloak `homelab` realm and `langfuse` client. Create that client in Keycloak and update the generated `langfuse-secrets` client secret to match.
