#! /usr/bin/env bash

# VM_NAME, NET_NAME, VOL_NAME

set +e

echo "Destroying existing libvirt resources"
sudo virsh dominfo "${VM_NAME}" &> /dev/null
if [[ $? == 0 ]]; then
    sudo virsh undefine "${VM_NAME}"
    sudo virsh destroy "${VM_NAME}"
fi
sudo virsh net-info "${NET_NAME}" &> /dev/null
if [[ $? == 0 ]]; then
    sudo virsh net-undefine "${NET_NAME}"
    sudo virsh net-destroy "${NET_NAME}"
fi
sudo virsh vol-info --pool default "${VOL_NAME}" &> /dev/null
if [[ $? == 0 ]]; then
    sudo virsh vol-delete --pool default "${VOL_NAME}"
fi
