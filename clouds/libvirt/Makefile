THIS_DIR = .

export root_dir := $(shell cd ${THIS_DIR}/../.. && pwd)
export BASH_ENV := $(shell ${THIS_DIR}/../../.env)
SHELL := bash

NET_NAME ?= cluster1-net
VM_NAME  ?= cluster1-vm
VOL_NAME ?= $(VM_NAME).qcow2

HOST_IP  ?= 192.168.126.10

NET_CONFIG_TEMPLATE := $(THIS_DIR)/net.xml.template
NET_CONFIG          := $(THIS_DIR)/net.xml

SSH_KEY_DIR        := $(THIS_DIR)/.ssh
SSH_KEY_PUB_PATH   := $(SSH_KEY_DIR)/key.pub
SSH_KEY_PRIV_PATH  := $(SSH_KEY_DIR)/key

SSH_FLAGS := -o IdentityFile=$(SSH_KEY_PRIV_PATH) \
 			 -o UserKnownHostsFile=/dev/null \
 			 -o StrictHostKeyChecking=no
SSH_HOST  ?= joshgav@$(HOST_IP)

VM_OS_VARIANT ?= fedora36
VM_RAM_MB     ?= 18432
VM_CPU_CORES  ?= 6
VM_DISK_GB    ?= 50

.PHONY: destroy network machine ssh volume

destroy:
	VM_NAME=${VM_NAME} NET_NAME=${NET_NAME} VOL_NAME=${VOL_NAME} \
		${THIS_DIR}/destroy.sh

$(SSH_KEY_DIR):
	@echo Creating SSH key dir
	mkdir $@

$(SSH_KEY_PRIV_PATH): $(SSH_KEY_DIR)
	@echo "No private key $@ found, generating a private-public pair"
    # -N "" means no password
	ssh-keygen -f $@ -N ""
	chmod 400 $@

$(SSH_KEY_PUB_PATH): $(SSH_KEY_PRIV_PATH)

ssh: $(SSH_KEY_PRIV_PATH)
	ssh $(SSH_FLAGS) $(SSH_HOST)

$(NET_CONFIG): $(NET_CONFIG_TEMPLATE)
	sed -e 's/REPLACE_NET_NAME/$(NET_NAME)/' \
		-e 's/REPLACE_HOST_IP/$(HOST_IP)/' \
	    $(NET_CONFIG_TEMPLATE) > $@

network: $(NET_CONFIG)
	sudo virsh net-define "$(NET_CONFIG)"
	echo server=/api.cluster1.joshgav.com/192.168.126.10 | sudo tee /etc/NetworkManager/dnsmasq.d/aio.conf
	echo -e "[main]\ndns=dnsmasq" | sudo tee /etc/NetworkManager/conf.d/aio.conf
	sudo systemctl reload NetworkManager.service
	sudo virsh net-start "$(NET_NAME)"
	sudo virsh net-autostart "$(NET_NAME)"

machine: network $(SSH_KEY_PUB_PATH)
	virt-install \
		--connect qemu:///system \
		--name "$(VM_NAME)" \
		--memory "$(VM_RAM_MB)" \
		--vcpus "$(VM_CPU_CORES)" \
		--os-variant "$(VM_OS_VARIANT)" \
		--install "$(VM_OS_VARIANT)" \
		--initrd-inject ./ks.cfg \
		--extra-args "console=ttyS0,115200 inst.ks=file:/ks.cfg" \
		--network "network:$(NET_NAME),mac=52:54:00:ee:42:e1" \
		--graphics none \
		--events on_reboot=restart \
		--disk pool=default,size=$(VM_DISK_GB) \
		--boot hd,cdrom

volumes:
	for devname in vdb vdc vdd vde vdf vdg vdh; do \
		./apply-volume.sh $${devname} ${VM_NAME}; \
	done

destroy-volumes:
	for devname in vdb vdc vdd vde vdf vdg vdh; do \
		virsh detach-disk --domain cluster1-vm /var/lib/libvirt/images/cluster1-vm-$${devname}.qcow2 --persistent; \
		virsh vol-delete --pool default cluster1-vm-$${devname}.qcow2; \
	done