#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

windows_iso_name=SERVER_EVAL_x64FRE_en-us.iso
tempdir=$(mktemp -d)

mkdir -p ${tempdir}/mnt/windows
sudo mount ${this_dir}/windows/${windows_iso_name} ${tempdir}/mnt/windows

cp -rp ${tempdir}/mnt/windows ${tempdir}
sudo umount ${tempdir}/mnt/windows

sudo cp ${this_dir}/windows/autounattend.xml ${tempdir}/windows
sudo cp ${this_dir}/windows/post-install.ps1 ${tempdir}/windows

genisoimage -quiet -allow-limited-size -no-emul-boot \
    -b boot/etfsboot.com -boot-load-seg 0x07C0 \
    -boot-load-size 8 -lJR \
    -o ${this_dir}/windows/SERVER_unattended.iso \
    ${tempdir}/windows

qemu-img create -f qcow2 ${this_dir}/windows/windows2022.qcow2 12G

# virtio-win is required
# learn more about virtio-win and download it at https://github.com/virtio-win/virtio-win-pkg-scripts
# sudo dnf install virtio-win libvirtd virt-install

virtio_win_iso_path=/usr/share/virtio-win/virtio-win.iso
sudo setfacl -m u:qemu:rx ${this_dir}

virt-install --connect qemu:///system \
    --name windows2022 --ram 2048 --vcpus 2 \
    --network network=default,model=virtio \
    --cdrom ${this_dir}/windows/SERVER_unattended.iso \
    --disk path=${this_dir}/windows/windows2022.qcow2,format=qcow2,device=disk,bus=virtio \
    --disk path=${virtio_win_iso_path},device=cdrom \
    --os-variant win2k22

# https://docs.openshift.com/container-platform/4.13/virt/virtual_machines/virtual_disks/virt-uploading-local-disk-images-virtctl.html
# name from https://github.com/kubevirt/common-templates/blob/master/templates/windows2k22.tpl.yaml#L79-L92
# and https://github.com/kubevirt/common-templates/blob/master/templates/windows2k22.tpl.yaml#L192
kubectl virt image-upload dv win2k22 --size=13Gi --force-bind \
    --uploadproxy-url=https://cdi-uploadproxy-openshift-cnv.apps.rosa.rosa1.5f1x.p3.openshiftapps.com/ \
    --image-path=${this_dir}/windows/windows2022.qcow2 \
    --namespace openshift-virtualization-os-images
