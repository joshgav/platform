#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

source ${root_dir}/lib/requirements.sh
ssh_key_path=${root_dir}/.ssh

install_aws_cli
install_openshift_install

echo "INFO: aws sts get-caller-identity"
aws sts get-caller-identity

workdir=${root_dir}/temp/_workdir
if [[ -d ${workdir} ]]; then rm -rf ${workdir}; fi
mkdir -p ${workdir}

export OPENSHIFT_CLUSTER_NAME=aws-ipi
export OPENSHIFT_SSH_PUBLIC_KEY="$(cat ${ssh_key_path}/id_rsa.pub)"
cat ${this_dir}/install-config.yaml.tpl | envsubst 1> ${workdir}/install-config.yaml

openshift-install create cluster --dir ${workdir}
