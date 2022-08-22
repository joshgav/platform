#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${root_dir}/lib/olm.sh

create_subscription eclipse-che openshift-operators

# TODO: wait for readiness

echo "INFO: render and apply manifests"
kustomize build ${this_dir}/base | oc apply -f -
