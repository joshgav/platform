#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

if [[ ! -d ${this_dir}/tf ]]; then
    git clone https://github.com/openshift-cs/terraform-vpc-example ${this_dir}/tf
fi

pushd ${this_dir}/tf

terraform init

terraform plan -out ${CLUSTER_NAME}.tfplan \
    -var region=${AWS_REGION} \
    -var 'subnet_azs=["usw2-az1", "usw2-az2", "usw2-az3"]' \
    -var cluster_name=${CLUSTER_NAME} \
    -var 'vpc_cidr=10.0.0.0/16' \
    -var 'subnet_cidr_prefix=24' \
    -var private_subnets_only=false \
    -var single_az_only=false

terraform apply rosa1.tfplan

popd
