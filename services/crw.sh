#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

source ${root_dir}/lib/operators.sh

create_subscription codeready-workspaces2 openshift-operators

config_path=${root_dir}/config/che

echo "INFO: render and apply manifests"
kustomize build ${config_path} | oc apply -f -
