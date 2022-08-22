#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
source ${root_dir}/lib/olm.sh
source ${root_dir}/lib/yaml.sh

echo "INFO: install operator subscription"
oc apply -f - <<EOF
    apiVersion: operators.coreos.com/v1alpha1
    kind: Subscription
    metadata:
        name: amq-streams
        namespace: openshift-operators
    spec:
        name: amq-streams
        source: redhat-operators
        sourceNamespace: openshift-marketplace
        channel: stable
        installPlanApproval: Automatic
EOF

await_resource_ready "kafka"

apply_kustomize_dir ${this_dir}/broker
