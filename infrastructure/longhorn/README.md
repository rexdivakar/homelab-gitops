# Longhorn

Longhorn provides persistent storage for the single-node homelab cluster.

This configuration intentionally uses one replica:

- It allows scheduling on a single-node cluster.
- It keeps resource use low.
- It does not protect data from node or disk failure.

Before syncing Longhorn, install the Debian 12 prerequisites on the Kubernetes node:

```sh
sudo apt update
sudo apt install -y open-iscsi nfs-common
sudo systemctl enable --now iscsid
```

## First Sync

For a fresh install through Argo CD, use the bootstrap helper:

```sh
scripts/bootstrap-longhorn.sh
```

Longhorn's chart includes a `pre-upgrade` hook. Argo CD maps Helm hooks into Argo CD sync hooks, so that hook can run as a `PreSync` Job even on a fresh Argo CD install and block the first sync before Longhorn service account/RBAC resources are ready. The bootstrap helper performs the first sync without hooks, then restores normal automated sync.

## Verify

```sh
kubectl get pods -n longhorn-system
kubectl get storageclass
kubectl apply -f infrastructure/longhorn/test-pvc.yaml
kubectl get pvc longhorn-test-pvc -n default
kubectl exec -n default longhorn-test-pod -- cat /data/longhorn-test.txt
```

Clean up the test resources when finished:

```sh
kubectl delete -f infrastructure/longhorn/test-pvc.yaml
```
