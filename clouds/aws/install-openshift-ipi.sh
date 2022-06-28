#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${root_dir}/lib/requirements.sh

install_aws_cli
install_openshift_install

echo "INFO: aws sts get-caller-identity"
aws sts get-caller-identity

## TODO: generate unique SSH key pair

workdir=${root_dir}/temp/_workdir
if [[ -d ${workdir} ]]; then rm -rf ${workdir}; fi
mkdir -p ${workdir}

export OPENSHIFT_SSH_PUBLIC_KEY=$(cat ${OPENSHIFT_SSH_PUBLIC_KEY_PATH})
cat ${this_dir}/install-config.yaml.tpl | envsubst 1> ${workdir}/install-config.yaml

openshift-install create cluster --dir ${workdir}
