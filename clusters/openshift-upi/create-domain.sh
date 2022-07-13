#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${this_dir}/vars.sh
source ${this_dir}/requirements.sh

wd=${this_dir}/_wrkdir
libvirt_images_dir=/var/lib/libvirt/sno-images
mkdir -p ${libvirt_images_dir}
export LIBVIRT_DEFAULT_URI='qemu:///system'

export domain_name=${1:-sno}
export rhcos_path=${2:-${wd}/rhcos-live.iso}
export runtime_disk_path=${3:-"${libvirt_images_dir}/${domain_name}.qcow"}

if [[ -n "${FORCE}" ]]; then
    domstate=$(virsh domstate ${domain_name} 2> /dev/null || true)
    if [[ "${domstate}" == "running" ]]; then
        echo "stop domain"
        virsh destroy ${domain_name}
        domstate=$(virsh domstate ${domain_name} 2> /dev/null || true)
    fi
    if [[ "${domstate}" == "shut off" ]]; then
        echo "undefine domain"
        virsh undefine ${domain_name}
    fi
    echo "delete runtime disk"
    rm -f ${runtime_disk_path}
fi

if [[ ! -e "${runtime_disk_path}" ]]; then
    echo "create new runtime disk at ${runtime_disk_path}"
    qemu-img create -f qcow2 ${runtime_disk_path} 120G
fi

echo "write domain xml"
cat ${this_dir}/machine/domain.xml.template | \
    envsubst '${domain_name} ${rhcos_path} ${runtime_disk_path}' \
        > ${wd}/domain.xml

echo "define domain"
virsh define ${wd}/domain.xml --validate

echo "start domain"
virsh start ${domain_name}
