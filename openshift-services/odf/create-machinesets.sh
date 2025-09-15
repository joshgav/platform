#! /usr/bin/env bash

INSTANCE_TYPE=${1:-"m5.4xlarge"}
# INSTANCE_TYPE=${1:-"n2-highmem-8"}

original_name=worker
new_name=worker-ocs

for existing_ms_name in $(oc get -n openshift-machine-api machinesets -o name | grep ${original_name} | grep -v ${new_name} ); do
  new_ms_name=$(echo ${existing_ms_name} | sed "s/${original_name}/${new_name}/")
  echo "INFO: Creating copy of machine set ${existing_ms_name} as ${new_ms_name}"

  ms=$(oc get -n openshift-machine-api "${existing_ms_name}" -ojson)
  ms=$(echo "${ms}" | jq 'del( .metadata.uid, .metadata.managedFields, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .metadata.annotations, .status)')
  ms=$(echo "${ms}" | jq "(.metadata.name, .spec.selector.matchLabels[\"machine.openshift.io/cluster-api-machineset\"], .spec.template.metadata.labels[\"machine.openshift.io/cluster-api-machineset\"]) |= sub(\"${original_name}\";\"${new_name}\")")
  ms=$(echo "${ms}" | jq '(.spec.template.spec.metadata.labels["cluster.ocs.openshift.io/openshift-storage"]) |= ""')
  ms=$(echo "${ms}" | jq ".spec.template.spec.providerSpec.value.instanceType |= \"${INSTANCE_TYPE}\"")

  echo "${ms}" | oc apply -f -
done
