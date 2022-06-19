# Volumes

## Helpers

**Delete "Failed" PVs**:

```bash
kubectl get pv | grep Failed | awk '{print $1}' | xargs kubectl delete pv
```

**[Re]create static PVs**:

```bash
(cd ./clouds/libvirt && sudo -E make volumes)
```

**Delete a static PV**:

```bash
devname=vdc

# ensure any referring PVC is deleted
kubectl delete pv local-pv-${devname}
sudo virsh detach-disk --persistent --domain cluster1-vm --target ${devname}
sudo virsh vol-delete --pool default --vol /var/lib/libvirt/images/cluster1-vm-${devname}.qcow2
```
