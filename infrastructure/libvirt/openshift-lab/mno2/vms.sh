#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi

export VM_RAM='16384'
export VM_CPU='8'
export VM_NETWORK=mno2
export VM_DISK_SIZE=120
export VM_DISK_POOL=cluster-images
export VM_DISK_PATH=/var/lib/libvirt/cluster-images
export VM_ISO_PATH=/opt/agent.x86_64.iso
export VIRSH_DEFAULT_CONNECT_URI=qemu:///system

## -c to put each object in a single line
for VM in $(jq -c '.[]' ${this_dir}/vms.json); do

echo "Operating on VM $(echo ${VM} | jq)"

VM_NAME=$(echo "${VM}" | jq -r '.name')
VM_MAC=$(echo "${VM}" | jq -r '.macAddress')

virt-install \
    --noautoconsole \
    --connect qemu:///system \
    --name "${VM_NAME}" \
    --memory "${VM_RAM}" \
    --vcpus "${VM_CPU}" \
    --cdrom "${VM_ISO_PATH}" \
    --network "network=${VM_NETWORK},mac=${VM_MAC}" \
    --disk "size=${VM_DISK_SIZE},pool=${VM_DISK_POOL}" \
    --boot hd,cdrom \
    --events on_reboot=restart \
    --os-variant rhel9.4
done
