#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

ssh_key_path=${root_dir}/.ssh
mkdir -p "${ssh_key_path}"

if [[ ! -e "${ssh_key_path}/id_rsa" ]]; then
    ssh-keygen -t rsa -b 4096 -C "user@openshift" -f "${ssh_key_path}/id_rsa" -N ''
fi

echo "INFO: aws sts get-caller-identity"
aws sts get-caller-identity

# set up workdir
workdir=${this_dir}/_workdir
if [[ -e ${workdir} && -z "${RESUME}" && -z "${OVERWRITE}" ]]; then
    echo "WARNING: workdir already exists, set OVERWRITE=1 to remove or RESUME=1 to continue"
    exit 2
elif [[ -e ${workdir} && -n "${RESUME}" ]]; then
    echo "INFO: continuing from existing workdir"
elif [[ -e ${workdir} && -n "${OVERWRITE}" ]]; then
    rm -rf ${workdir}
    mkdir -p "${workdir}"
else
    mkdir -p "${workdir}"
fi

export SSH_PUBLIC_KEY="$(cat ${ssh_key_path}/id_rsa.pub)"
cat ${this_dir}/install-config.yaml.tpl | envsubst 1> ${workdir}/install-config.yaml

openshift-install create cluster --dir ${workdir} --log-level debug
