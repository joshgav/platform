#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

source ${this_dir}/prep.sh

echo
echo "INFO: aws --version"

aws --version
echo
echo "INFO: aws sts get-caller-identity"
aws sts get-caller-identity

echo
echo "INFO: openshift-install version"
openshift-install version

## TODO: generate unique SSH key pair

workdir=${this_dir}/_workdir
if [[ -d ${workdir} ]]; then rm -rf ${workdir}; fi
mkdir -p ${workdir}

echo
export OPENSHIFT_SSH_PUBLIC_KEY=$(cat ${OPENSHIFT_SSH_PUBLIC_KEY_PATH})
cat ${this_dir}/install-config.yaml.tpl | envsubst 1> ${workdir}/install-config.yaml

openshift-install create cluster --dir ${workdir}
