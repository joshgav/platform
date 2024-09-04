#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi
if [[ -e "${this_dir}/.env" ]]; then source "${this_dir}/.env"; fi

WORKER_REGEXP='-worker-'
for WORKER_MACHINESET in $(oc get machinesets.machine.openshift.io -n openshift-machine-api -oname | grep -e "${WORKER_REGEXP}")
do
    echo "creating corresponding VM machineset for ${WORKER_MACHINESET}"
    oc get -n openshift-machine-api ${WORKER_MACHINESET} -ojson | jq '
      del(.metadata.uid, .metadata.managedFields, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .metadata.annotations, .status) | 
      (.metadata.name, .spec.selector.matchLabels["machine.openshift.io/cluster-api-machineset"], .spec.template.metadata.labels["machine.openshift.io/cluster-api-machineset"]) |= sub("worker";"metal-worker") | 
      (.spec.replicas) |= 0 |
      (.spec.template.spec.providerSpec.value.instanceType) |= "m7i.metal-24xl"' |
        oc apply -f -
done
