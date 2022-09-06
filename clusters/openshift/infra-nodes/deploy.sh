#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi

export INFRASTRUCTURE_NAME=$(oc get infrastructures.config.openshift.io cluster -o json | \
                                jq -r '.status.infrastructureName')
export CLOUD_CREDENTIALS_SECRET_NAME=aws-cloud-credentials

# create machine sets for infra
zones=(
    us-east-1a
    us-east-1b
    us-east-1c
    us-east-1d
    us-east-1e
    us-east-1f
)

for AWS_ZONE in "${zones[@]}"; do
    export AWS_ZONE
    export RHCOS_AMI_ID=$(oc get machinesets.machine.openshift.io --namespace openshift-machine-api \
                            ${INFRASTRUCTURE_NAME}-worker-${AWS_REGION}a -ojson | \
                                jq -r '.spec.template.spec.providerSpec.value.ami.id')
    export MACHINESET_NAME=${INFRASTRUCTURE_NAME}-infra-${AWS_ZONE}
    cat ${this_dir}/machineset.yaml.tpl | envsubst | oc apply --validate=false -f -
done
