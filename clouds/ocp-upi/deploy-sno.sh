#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${this_dir}/vars.sh
source ${this_dir}/requirements.sh

install_openshift_install
install_coreos_installer

wd=${this_dir}/_wrkdir
rm -rf "${wd}"
mkdir -p "${wd}"

export pull_secret=$(cat ${this_dir}/secrets/pull-secret.txt)
export sshuser_public_key=$(cat ${this_dir}/secrets/sshuser.pub)
cat ${this_dir}/install-config.yaml | envsubst '${pull_secret} ${sshuser_public_key}' \
    > ${wd}/install-config.yaml

# openshift-install create manifests \
#     --dir "${wd}" \
#     --log-level debug

openshift-install create single-node-ignition-config --dir "${wd}"
download_rhcos_live_iso "${wd}"

coreos-installer iso ignition embed ${wd}/rhcos-live.iso \
    --ignition-file ${wd}/bootstrap-in-place-for-live-iso.ign

karg_console='console=ttyS0,115200'
if ! coreos-installer iso kargs show ${wd}/rhcos-live.iso | grep -q ${karg_console}; then
    coreos-installer iso kargs modify ${wd}/rhcos-live.iso --append "${karg_console}"
fi

sno_domain_name=sno
${this_dir}/create-domain.sh ${sno_domain_name}

# Ctrl+] to release
virsh console ${sno_domain_name}

# use ide drive for live iso
# ensure dns is accessible
# ensure machineCIDR is right

# https://github.com/kubernetes/kubernetes/issues/56850
# add to systemd unit file for kubelet.service:
# [Service]
# CPUAccounting=true
# MemoryAccounting=true