#! /usr/bin/env bash

# taken from https://github.com/red-hat-storage/ocs-training/blob/master/training/modules/ocs4/attachments/create_machinesets.sh

## Create Machineset from previous template just modifiying the instance type
for MACHINESET in $(oc get -n openshift-machine-api machinesets -o name | grep -v ocs ); do
  oc get -n openshift-machine-api "$MACHINESET" -o json | jq '
      del( .metadata.uid, .metadata.managedFields, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status) | 
      (.metadata.name, .spec.selector.matchLabels["machine.openshift.io/cluster-api-machineset"], .spec.template.metadata.labels["machine.openshift.io/cluster-api-machineset"]) |= sub("worker";"workerocs") | 
      (.spec.template.spec.providerSpec.value.instanceType) |= "m5.4xlarge" |
      (.spec.template.spec.metadata.labels["cluster.ocs.openshift.io/openshift-storage"]) |= ""' |
        oc apply -f -
done
