#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi
if [[ -e "${this_dir}/.env" ]]; then source "${this_dir}/.env"; fi

oc apply -f ${this_dir}/cluster-autoscaler.yaml

## for AWS only
# infra_name=$(oc get infrastructures.config.openshift.io cluster -ojson | jq -r '.status.infrastructureName')
# base_machineset_name=${infra_name}-worker-${AWS_REGION}
# for zone_id in "a" "b" "c"; do
#     export MACHINESET_NAME=${base_machineset_name}${zone_id}
#     echo "INFO: creating MachineAutoscaler for MachineSet ${MACHINESET_NAME}"
#     cat ${this_dir}/machine-autoscaler.yaml.tpl | envsubst | oc apply -f -
# done

for MACHINESET_NAME in $(oc get machinesets.machine.openshift.io -n openshift-machine-api -o json | jq -r '.items[].metadata.name'); do
    export MACHINESET_NAME
    echo "INFO: creating MachineAutoscaler for MachineSet ${MACHINESET_NAME}"
    cat ${this_dir}/machine-autoscaler.yaml.tpl | envsubst | oc apply -f -
done
