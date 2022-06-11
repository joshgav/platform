# Install with kubeadm

## Configuration

- APIs: <https://github.com/kubernetes/kubernetes/tree/master/cmd/kubeadm/app/apis/kubeadm>
- Calico: <https://projectcalico.docs.tigera.io/reference/installation/api>

## Troubleshooting

### Custom resolv.conf

By default, kubelet will copy the host's `/etc/resolv.conf` into DNS pods, and
CoreDNS is configured to use that as the list of last resort. If the host's
`/etc/resolv.conf` points to another local endpoint at 127.0.0.1 (for example
when using systemd-resolvd) this will fail.  To work around this create an
alternate resolv.conf file and specify it as an extra arg for kubelet in the
InitConfiguration:

```yaml
kubeletExtraArgs:
  "resolv-conf": "/etc/resolv.conf.k8s"
```

### NetworkManager

NetworkManager should be configured not to manage virtual interfaces created by
CNI plugins. For example, for Calico/Tigera, interfaces named `cali*` or `tunl*`
should not be managed by NetworkManager.

Extra configuration can be added by dropping files in
`/etc/NetworkManager/conf.d/`. For example, add the following to a file named
`calico.conf` for Calico:

```ini
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico
```
