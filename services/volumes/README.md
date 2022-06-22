# Volumes

## Helpers

**Delete only "Failed" PVs**:

```bash
source clouds/libvirt/volumes.sh
kubectl get pv | grep Failed | awk '{print $1}' | sed 's/local-pv-\(.*\)/\1/' | xargs delete_local_pv
```

**[Re]create static PVs**:

- Root make task includes `libvirt-`
- `-E` includes environment, specifically `KUBECONFIG` if set

```
sudo -E make [libvirt-]pvs
```
