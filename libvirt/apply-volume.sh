# root_dir

# apply_volume
function apply_volume {
    local device_name=${1:-"vdb"}
    local vm_name=${2:-"cluster1-vm"}

	virsh vol-create-as \
		--pool default \
		--name ${vm_name}-${device_name}.qcow2 \
		--capacity 11000000000
	virsh attach-disk \
		--domain ${vm_name} \
		--source /var/lib/libvirt/images/${vm_name}-${device_name}.qcow2 \
		--target ${device_name} \
		--targetbus virtio \
		--persistent
	${root_dir}/config/volumes/pv.sh "${device_name}"
}
apply_volume "${@}"
