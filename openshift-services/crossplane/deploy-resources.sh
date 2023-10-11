#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh
source ${root_dir}/lib/aws.sh

if ! default_vpc_exists ${AWS_REGION}; then
    echo "INFO: creating default VPC in region ${AWS_REGION}"
    aws ec2 create-default-vpc
else
    echo "INFO: using existing default VPC in region ${AWS_REGION}"
fi

export target_namespace=crossplane-system
if [[ -n "${DESTROY}" ]]; then
    kubectl_action=delete
else
    kubectl_action=apply
fi

cat ${this_dir}/resources/rds.yaml.tpl | envsubst '${target_namespace} ${AWS_REGION}' | kubectl ${kubectl_action} -f -

# kubectl ${kubectl_action} -f ${this_dir}/resources/xr/definition.yaml
# kubectl ${kubectl_action} -f ${this_dir}/resources/xr/composition.yaml
# kubectl ${kubectl_action} -n ${CROSSPLANE_SYSTEM_NAMESPACE} -f ${this_dir}/resources/xr/postgresqlinstance.yaml
