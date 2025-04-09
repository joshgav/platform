#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi

export VM_DISK_PATH=/var/lib/libvirt/cluster-images
export VIRSH_DEFAULT_CONNECT_URI=qemu:///system

## -c to put each object in a single line
for VM in $(jq -c '.[]' ${this_dir}/vms.json); do

echo "Operating on VM $(echo ${VM} | jq)"

VM_NAME=$(echo "${VM}" | jq -r '.name')

virsh destroy ${VM_NAME} && sudo virsh undefine ${VM_NAME}
rm -f /var/lib/libvirt/cluster-images/${VM_NAME}.qcow2

done
