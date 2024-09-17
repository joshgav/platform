## OpenShift Lab Notes

## Resources

- https://github.com/kubealex/libvirt-k8s-provisioner
- https://computingforgeeks.com/how-to-deploy-openshift-container-platform-on-kvm/
- https://github.com/redhatci/ansible-collection-redhatci-ocp

## Notes

### Configure External DNS

Create A records in Route53:

```
# not required, just for easy access
equinix.joshgav.com                ${HOST_IP}
# for external OpenShift access
api.sno1.equinix.joshgav.com       ${HOST_IP}
*.apps.sno1.equinix.joshgav.com    ${HOST_IP}
```

### Install tools on host (hypervisor)

Install KVM and libvirt:

```bash
sudo dnf install qemu-kvm libvirt virt-install virt-viewer
for drv in qemu network nodedev nwfilter secret storage interface; do
    sudo systemctl enable --now virt${drv}d{,-ro,-admin}.socket
done
```

Install network tools:

```bash
dnf install nftables
dnf install bind-utils
```

### Create network on host (hypervisor) for OpenShift cluster

Apply libvirt XML to define a network fit for an SNO cluster.

Perhaps adjust the following to account for other co-hosted networks:

- bridge name/number from `virbr1`
- bridge MAC address from `52:54:00:e0:8d:fe`
- base network CIDR from `192.168.126.0/24`
- static MAC addresses for VMs - must match agent-config.yaml and vm.xml
- OpenShift cluster name

```xml
<network>
  <name>${OPENSHIFT_CLUSTER_NAME}</name>
  <forward mode='nat'/>
  <bridge name='virbr1' stp='on' delay='0'/>
  <mtu size='1500'/>
  <mac address='52:54:00:e0:8d:fe'/>
  <domain name='${OPENSHIFT_CLUSTER_NAME}.equinix.joshgav.com' localOnly='yes'/>
  <dns enable='yes'>
    <host ip='192.168.126.10'>
      <hostname>api.${OPENSHIFT_CLUSTER_NAME}.equinix.joshgav.com</hostname>
      <hostname>api-int.${OPENSHIFT_CLUSTER_NAME}.equinix.joshgav.com</hostname>
      <hostname>master0.${OPENSHIFT_CLUSTER_NAME}.equinix.joshgav.com</hostname>
      <hostname>*.apps.${OPENSHIFT_CLUSTER_NAME}.equinix.joshgav.com</hostname>
    </host>
    <forwarder addr="8.8.8.8"/>
  </dns>
  <ip family='ipv4' address='192.168.126.1' prefix='24' localPtr="yes">
    <dhcp>
      <range start='192.168.126.100' end='192.168.126.200'/>
      <host ip='192.168.126.10' name='master0' mac='52:54:00:ee:42:e1' />
    </dhcp>
  </ip>
</network>
```

Copy the XML into a file named `net.xml` and run:

```bash
sudo virsh net-define net.xml
sudo virsh net-start sno1
sudo virsh net-autostart sno1
```

Route traffic from the hypervisor host to the OpenShift VMs. This enables kubectl/oc commands to work from hypervisor.

Add to `/etc/NetworkManager/conf.d/00-use_dnsmasq.conf`:

```ini
[main]
dns=dnsmasq
```

Add to `/etc/NetworkManager/dnsmasq.d/00-use_internal_dns.conf`:

Consider if a different filename is needed if another network already exists.

```
server=/api.sno1.equinix.joshgav.com/192.168.126.10
```

Restart NetworkManager: `sudo systemctl restart NetworkManager`

Test that internal address is returned by default:

```bash
nslookup api.sno1.equinix.joshgav.com
```

### Create Agent ISO

Copy [agent-config.yaml](./agent-config.template.yaml) and [install-config.yaml](./install-config.template.yaml) into `_workdir` and adjust values.

Ensure MAC address matches that configured for the VMs

Ensure rendezvous IP reflects correct IP address

Ensure machine network matches libvirt network

Download openshift-install and oc from <https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast/>

- https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast/openshift-client-linux.tar.gz
- https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast/openshift-install-linux.tar.gz

Create an ISO with `openshift-install agent create image --dir _workdir`

Copy ISO to a root-accessible location, e.g. `sudo cp ./_workdir/agent.x86_64.iso /opt/`.

### Create VM

Create a VM that boots with an agent-install ISO.

Set network name and static MAC address to match a static entry in DHCP server.

```bash
virt-install \
    --noautoconsole \
    --connect qemu:///system \
    --name "master0" \
    --memory "16384" \
    --vcpus "8" \
    --cdrom /opt/agent.x86_64.iso \
    --network "network=sno1,mac=52:54:00:ee:42:e1" \
    --disk size=120 \
    --boot hd,cdrom \
    --os-variant rhel9.4
```

Check status and wait for install with `openshift-install agent wait-for install-complete --dir _workdir`.

To remove a VM: `sudo virsh destroy master0 && sudo virsh undefine master0`

### Forward Internet traffic to cluster

Forward traffic from host on public Internet to VM.
Masquerade rules for traffic outbound from the VM are already created by libvirt.

```bash
nft insert rule ip filter LIBVIRT_FWI tcp dport 443 accept
nft insert rule ip filter LIBVIRT_FWI tcp dport 6443 accept
nft add chain ip nat PREROUTING { type nat hook prerouting priority -100 \; }
nft add rule ip nat PREROUTING iifname "bond0" tcp dport 443 dnat to 192.168.126.10
nft add rule ip nat PREROUTING iifname "bond0" tcp dport 6443 dnat to 192.168.126.10
```

It is not supported to redirect traffic from a different port to 6443 for the
api endpoint, but it is possible, see
<https://access.redhat.com/solutions/4665121>. Be sure to change kubeconfig or
the `oc login --server` parameter to the redirected port.

```bash
nft add rule ip nat PREROUTING iifname "bond0" tcp dport 10443 dnat to 192.168.126.10:6443
```

It is possible to change the port the router listens on, see
<https://access.redhat.com/solutions/6784921>, but internal redirects (e.g., for
OAuth login) won't include the port in the URL.
