## OpenShift Lab Notes

## Resources

- https://github.com/kubealex/libvirt-k8s-provisioner
- https://computingforgeeks.com/how-to-deploy-openshift-container-platform-on-kvm/

## Notes

Libvirt XML for creating a network fit for a SNO cluster.

```xml
<network>
  <name>sno1-net</name>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mtu size='1500'/>
  <mac address='52:54:00:e0:8d:fe'/>
  <domain name='sno1.equinix.joshgav.com' localOnly='yes'/>
  <dns enable='yes'>
    <host ip='192.168.122.10'>
      <hostname>api.sno1.equinix.joshgav.com</hostname>
      <hostname>master01.sno1.equinix.joshgav.com</hostname>
      <hostname>*.apps.sno1.equinix.joshgav.com</hostname>
    </host>
    <forwarder addr="8.8.8.8"/>
  </dns>
  <ip family='ipv4' address='192.168.122.1' prefix='24' localPtr="yes">
    <dhcp>
      <range start='192.168.122.100' end='192.168.122.200'/>
      <host ip='192.168.122.10' name='master01' mac='52:54:00:ee:42:e1' />
    </dhcp>
  </ip>
</network>
```

---

To route traffic from the host to the OpenShift VMs:

Add to `/etc/NetworkManager/conf.d`:
```ini
[main]
dns=dnsmasq
```

Add to `/etc/NetworkManager/dnsmasq.d`:
```
server=/api.sno1.equinix.joshgav.com/192.168.122.10
```

Copy agent-config.yaml and install-config.yaml into `_workdir`

```yaml
# agent-config.yaml
apiVersion: v1beta1
kind: AgentConfig
metadata:
  name: sno1-cluster
rendezvousIP: 192.168.122.10
additionalNTPSources:
- 0.rhel.pool.ntp.org
- 1.rhel.pool.ntp.org
hosts:
- hostname: master01
  role: master
  interfaces:
  - name: eno1
    macAddress: 52:54:00:ee:42:e1
```

Create an ISO with `openshift-install agent create --dir _workdir`

Use `openshift-install agent wait-for install-complete --dir _workdir`.

---

Create a VM that boots with an agent-install ISO.
Set static MAC address to match a static entry in DHCP server.

```bash
virt-install \
    --connect qemu:///system \
    --name "master01" \
    --memory "16384" \
    --vcpus "8" \
    --cdrom /opt/agent.x86_64.iso \
    --network "network:default,mac=52:54:00:ee:42:e1" \
    --disk size=120 \
    --boot hd,cdrom \
    --os-variant rhel9.4
```

Forward traffic from host on public Internet to VM.
Masquerade rules for traffic outbound from the VM are already created by libvirt.

```bash
nft insert rule ip filter LIBVIRT_FWI tcp dport 443 accept
nft add rule ip nat PREROUTING iifname "bond0" tcp dport 443 dnat to 192.168.122.10
```