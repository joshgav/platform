## Create Network and VM

### Configure External DNS

Create A records in DNS provider (e.g., Route53).

```text
cluster_name=mno2
# not required, just for easy access
openshift.joshgav.com                           ${HOST_IP}
# for external OpenShift access
api.${cluster_name}.openshift.joshgav.com       ${HOST_IP}
*.apps.${cluster_name}.openshift.joshgav.com    ${HOST_IP}
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
- base network CIDR from `192.168.136.0/24`
- static MAC addresses for VMs - must match agent-config.yaml and vm.xml
- OpenShift cluster name, e.g. `mno2`

Example for a SNO cluster:

```xml
<network>
  <name>${OPENSHIFT_CLUSTER_NAME}</name>
  <forward mode='nat'/>
  <bridge name='virbr1' stp='on' delay='0'/>
  <mtu size='1500'/>
  <mac address='52:54:00:e0:8d:fe'/>
  <domain name='${OPENSHIFT_CLUSTER_NAME}.openshift.joshgav.com' localOnly='yes'/>
  <dns enable='yes'>
    <host ip='192.168.136.10'>
      <hostname>api.${OPENSHIFT_CLUSTER_NAME}.openshift.joshgav.com</hostname>
      <hostname>api-int.${OPENSHIFT_CLUSTER_NAME}.openshift.joshgav.com</hostname>
      <hostname>master0.${OPENSHIFT_CLUSTER_NAME}.openshift.joshgav.com</hostname>
      <hostname>*.apps.${OPENSHIFT_CLUSTER_NAME}.openshift.joshgav.com</hostname>
    </host>
    <forwarder addr="8.8.8.8"/>
  </dns>
  <ip family='ipv4' address='192.168.136.1' prefix='24' localPtr="yes">
    <dhcp>
      <range start='192.168.136.100' end='192.168.136.200'/>
      <host ip='192.168.136.10' name='master0' mac='52:54:00:ee:42:e1' />
    </dhcp>
  </ip>
</network>
```

Copy the XML into a file named `net.xml` and run:

```bash
OPENSHIFT_CLUSTER_NAME=mno2
sudo virsh net-define net.xml
sudo virsh net-start ${OPENSHIFT_CLUSTER_NAME}
sudo virsh net-autostart ${OPENSHIFT_CLUSTER_NAME}
```

Route traffic from the hypervisor host to the OpenShift VMs. This enables kubectl/oc commands to work from hypervisor.

Add to `/etc/NetworkManager/conf.d/00-use_dnsmasq.conf`:

```ini
[main]
dns=dnsmasq
```

Add to `/etc/NetworkManager/dnsmasq.d/00-use_internal_dns.conf`:

Consider if a different filename is needed if another network already exists.

This example uses custom VIPs for load balancers.

```
address=/api.mno2.openshift.joshgav.com/192.168.136.98
address=/apps.mno2.openshift.joshgav.com/192.168.136.99
```

Restart NetworkManager: `sudo systemctl restart NetworkManager`

Test that internal address is returned by default:

```bash
nslookup api.mno2.openshift.joshgav.com
```

### Create Agent ISO

- Download [openshift-install](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast/openshift-install-linux.tar.gz)
- Copy [agent-config.yaml](./agent-config.template.yaml) and [install-config.yaml](./install-config.template.yaml) into `workdir` and adjust values.
- Ensure MAC address matches that configured for the VMs
- Ensure rendezvous IP reflects correct IP address
- Ensure machine network matches libvirt network
- Download openshift-install and oc from <https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast/>
  - https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast/openshift-client-linux.tar.gz
  - https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast/openshift-install-linux.tar.gz
- Create an ISO with `openshift-install agent create image --dir workdir`
- Copy ISO to a root-accessible location, e.g. `sudo cp ./workdir/agent.x86_64.iso /opt/`.

### Root Disks

Create a partition on a block device on the host:

```bash
sudo parted /dev/vdb
mklabel msdos
mkpart primary 4MiB -1s
print
quit
sudo mkfs.ext4 /dev/vdb1
```

Mount the partition to a dir for use by libvirt:

```bash
# grab UUID for new partition
sudo blkid /dev/vdb1
# set params for partition in host fstab
UUID=7b86686b-6d10-47a2-9ad0-69b0ab9121c3
echo "UUID=${UUID} /var/lib/libvirt/cluster-images ext4 defaults 0 2" >> /etc/fstab
sudo systemctl daemon-reload
# create dir and mount new partition there
sudo mkdir /var/lib/libvirt/cluster-images
sudo mount /var/lib/libvirt/cluster-images
```

Create a libvirt pool to specify for VMs:

```bash
sudo virsh pool-create-as --name cluster-images --type dir --target /var/lib/libvirt/cluster-images
```

### Disks for PV/PVCs

Create a partition on a block device on the host:

```bash
sudo parted /dev/sdb
mklabel msdos
mkpart primary 4MiB -1s
print
quit
sudo mkfs.ext4 /dev/sdb1
```

Mount the partition to a path on the host for libvirt use:

```bash
sudo blkid /dev/sdb1
sudo su
echo 'UUID=4018757d-ad2b-4cc1-8ea6-6ea602eddcd4 /var/lib/libvirt/cluster-pvcs ext4 defaults 0 2' >> /etc/fstab
sudo systemctl daemon-reload
sudo mkdir /var/lib/libvirt/cluster-pvcs
sudo mount /var/lib/libvirt/cluster-pvcs
```

Create a libvirt pool for VMs:

```bash
sudo virsh pool-create-as --name cluster-pvcs --type dir --target /var/lib/libvirt/cluster-pvcs
```

You can specify the pool as a source for a disk for a new VM, or you can create volumes and attach them to running VMs.

Example of how to attach a disk to a running VM:

```bash
VM_NAME=master0
PVC_POOL_NAME=cluster-pvcs
PVC_VOLUME_CAPACITY=120GiB

sudo virsh vol-create-as --name ${VM_NAME}-pvc.qcow2 \
  --pool ${PVC_POOL_NAME} \
  --capacity ${PVC_VOLUME_CAPACITY} \
  --format qcow2

sudo virsh attach-disk --domain ${VM_NAME} \
  --source "/var/lib/libvirt/cluster-pvcs/${VM_NAME}-pvc.qcow2" \
  --target vdb --targetbus virtio \
  --driver qemu --subdriver qcow2 \
  --type disk --sourcetype file \
  --live --persistent
```

Now install the LVMO operator and create a LVMCluster resource.

Example LVMCluster:

```yaml
apiVersion: lvm.topolvm.io/v1alpha1
kind: LVMCluster
metadata:
  name: lvmcluster
  namespace: openshift-storage
spec:
  storage:
    deviceClasses:
    - name: vg1
      default: true
      fstype: ext4
      deviceSelector:
        paths:
        - /dev/vdb
      thinPoolConfig:
        name: thin-pool-1
        overprovisionRatio: 10
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
export VM_DISK_SIZE=120
export VM_POOL_NAME=cluster
export PVC_POOL_NAME=cluster-pvcs

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
    --disk "size=${VM_DISK_SIZE},pool=${PVC_POOL_NAME}" \
    --boot hd,cdrom \
    --events on_reboot=restart \
    --os-variant rhel9.4
```

To remove the VM:

```bash
sudo virsh destroy ${VM_NAME} && sudo virsh undefine ${VM_NAME}
sudo rm -f /var/lib/libvirt/cluster-images/${VM_NAME}.qcow2
```

### Connect to VM:

Check status and wait for install with `openshift-install agent wait-for install-complete --dir workdir`.

```
ssh -i .ssh/id_rsa core@192.168.136.10
journalctl --follow
```

To remove a VM: `sudo virsh destroy master0 && sudo virsh undefine master0`
