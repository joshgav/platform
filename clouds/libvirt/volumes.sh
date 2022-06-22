# root_dir

function create_local_pv {
    local device_name=${1:-"vdb"}
    local domain_name=${2:-"cluster1-vm"}
	local pool_name=${3:-"default"}

	virsh vol-create-as \
		--pool ${pool_name} \
		--name ${domain_name}-${device_name}.qcow2 \
		--capacity 11000000000
	virsh attach-disk \
		--domain ${domain_name} \
		--source /var/lib/libvirt/images/${domain_name}-${device_name}.qcow2 \
		--target ${device_name} \
		--targetbus virtio \
		--persistent
	${root_dir}/services/volumes/pv.sh "${device_name}"
}

function delete_local_pv {
    local devname=${1}
    local domain=${2:-"cluster1-vm"}
    local pool_name=${3:-"default"}

    if [[ -z "${devname}" ]]; then
        echo "ERROR: must supply device name"
        return
    fi

    # ensure any referring PVC is deleted
    kubectl delete pv "local-pv-${devname}"
    sudo virsh detach-disk --persistent --domain "${domain}" --target "${devname}"
    sudo virsh vol-delete --pool "${pool_name}" --vol "/var/lib/libvirt/images/${domain}-${devname}.qcow2"
}
