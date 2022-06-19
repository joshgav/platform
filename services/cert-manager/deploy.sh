#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

source ${root_dir}/lib/requirements.sh
install_cmctl

if ! cmctl check api &> /dev/null; then
    echo "INFO: cert-manager not discovered, attempting to install"
    cmctl experimental install --namespace cert-manager
else
    echo "INFO: cert-manager already installed"
fi

echo "INFO: render and apply manifests"
kustomize build ${this_dir}/libvirt | oc apply -f -
