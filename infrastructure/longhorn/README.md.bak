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
