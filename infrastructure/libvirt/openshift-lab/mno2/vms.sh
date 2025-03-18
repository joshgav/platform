export VM_NAME=master0
export VM_MAC="52:54:01:ee:42:e0"
export VM_DISK_NAME=${VM_NAME}
export VM_RAM='16384'
export VM_CPU='8'
export VM_NETWORK=mno2
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
    --disk "size=${VM_DISK_SIZE},pool=${VM_DISK_POOL}" \
    --boot hd,cdrom \
    --events on_reboot=restart \
    --os-variant rhel9.4

export VM_NAME=master1
export VM_DISK_NAME=${VM_NAME}
export VM_MAC="52:54:01:ee:42:e1"

virt-install \
    --noautoconsole \
    --connect qemu:///system \
    --name "${VM_NAME}" \
    --memory "${VM_RAM}" \
    --vcpus "${VM_CPU}" \
    --cdrom /opt/agent.x86_64.iso \
    --network "network=${VM_NETWORK},mac=${VM_MAC}" \
    --disk "size=${VM_DISK_SIZE},pool=${VM_DISK_POOL}" \
    --boot hd,cdrom \
    --events on_reboot=restart \
    --os-variant rhel9.4

export VM_NAME=master2
export VM_DISK_NAME=${VM_NAME}
export VM_MAC="52:54:01:ee:42:e2"

virt-install \
    --noautoconsole \
    --connect qemu:///system \
    --name "${VM_NAME}" \
    --memory "${VM_RAM}" \
    --vcpus "${VM_CPU}" \
    --cdrom /opt/agent.x86_64.iso \
    --network "network=${VM_NETWORK},mac=${VM_MAC}" \
    --disk "size=${VM_DISK_SIZE},pool=${VM_DISK_POOL}" \
    --boot hd,cdrom \
    --events on_reboot=restart \
    --os-variant rhel9.4
