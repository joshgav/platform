## Create Network and VM

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
address=/api.sno1.equinix.joshgav.com/192.168.126.10
address=/apps.sno1.equinix.joshgav.com/192.168.126.10
```

Restart NetworkManager: `sudo systemctl restart NetworkManager`

Test that internal address is returned by default:

```bash
nslookup api.sno1.equinix.joshgav.com
```

### Create Agent ISO

- Copy [agent-config.yaml](./agent-config.template.yaml) and [install-config.yaml](./install-config.template.yaml) into `_workdir` and adjust values.
- Ensure MAC address matches that configured for the VMs
- Ensure rendezvous IP reflects correct IP address
- Ensure machine network matches libvirt network
- Download openshift-install and oc from <https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast/>
  - https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast/openshift-client-linux.tar.gz
  - https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast/openshift-install-linux.tar.gz
- Create an ISO with `openshift-install agent create image --dir _workdir`
- Copy ISO to a root-accessible location, e.g. `sudo cp ./_workdir/agent.x86_64.iso /opt/`.

### Mount disk

Create a partition on a block device:

```bash
sudo parted /dev/sda
mklabel msdos
mkpart primary 4MiB -1s
print
quit
mkfs.ext4 /dev/sda1
```

Mount the partition to the dir:

```bash
sudo blkid /dev/sda1
echo 'UUID=d044579e-11eb-4bc2-a70d-17365a48f636 /var/lib/libvirt/cluster-images ext4 defaults 0 2' >> /etc/fstab
echo 'UUID=66677417-8f8c-402d-9a31-75a71f56d62c /var/lib/libvirt/cluster-images ext4 defaults 0 2' >> /etc/fstab
sudo systemctl daemon-reload
sudo mkdir /var/lib/libvirt/cluster-images
sudo mount /var/lib/libvirt/cluster-images/
```

Create a libvirt pool:

```bash
sudo virsh pool-create-as --name cluster --type dir --target /var/lib/libvirt/cluster-images
```

### Create VM

Create a VM that boots with an agent-install ISO.

Set network name and static MAC address to match a static entry in DHCP server.

```bash
export VM_NAME=master0
export VM_RAM='16384'
export VM_CPU='8'
export VM_NETWORK=sno1
export VM_MAC="52:54:00:ee:42:e1"
export VM_DISK_NAME=master0
export VM_DISK_SIZE=120
export VM_DISK_POOL=cluster
export VM_DISK_PATH=/var/lib/libvirt/cluster-images

export VIRSH_DEFAULT_CONNECT_URI=qemu:///system

virt-install \
    --noautoconsole \
    --connect qemu:///system \
    --name "${VM_NAME}" \
    --memory "${VM_RAM}" \
    --vcpus "${VM_CPU}" \
    --cdrom /opt/agent.x86_64.iso \
    --network "network=${VM_NETWORK},mac=${VM_MAC}" \
    --disk "size=${VM_DISK_SIZE},pool=${VM_POOL_NAME}" \
    --boot hd,cdrom \
    --events on_reboot=restart \
    --os-variant rhel9.4
```

To remove the VM:

```bash
sudo virsh destroy ${VM_NAME} && sudo virsh undefine ${VM_NAME}
rm /var/lib/libvirt/cluster-images/master0.qcow2
```

### Connect to VM:

Check status and wait for install with `openshift-install agent wait-for install-complete --dir _workdir`.

```
ssh -i .ssh/id_rsa core@192.168.126.10
journalctl --follow
```

To remove a VM: `sudo virsh destroy master0 && sudo virsh undefine master0`

## Resources

- https://github.com/kubealex/libvirt-k8s-provisioner
- https://computingforgeeks.com/how-to-deploy-openshift-container-platform-on-kvm/
- https://github.com/redhatci/ansible-collection-redhatci-ocp
