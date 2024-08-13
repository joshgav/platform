#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

if [[ ! -d ${this_dir}/tf-vpc ]]; then
    git clone https://github.com/openshift-cs/terraform-vpc-example ${this_dir}/tf-vpc
fi

pushd ${this_dir}/tf-vpc

terraform init

# defaults to these for us-east-2:
# -var 'subnet_azs=["use2-az1", "use2-az2", "use2-az3"]'
# defaults to these for us-east-1, see https://github.com/openshift-cs/terraform-vpc-example/blob/main/main.tf#L32:
# -var 'subnet_azs=["use1-az2", "use1-az4", "use1-az6"]'
terraform plan -out ${CLUSTER_NAME}.tfplan \
    -var region=${AWS_REGION} \
    -var cluster_name=${CLUSTER_NAME} \
    -var vpc_cidr=10.0.0.0/16 \
    -var subnet_cidr_prefix=24 \
    -var private_subnets_only=false \
    -var single_az_only=false

terraform apply ${CLUSTER_NAME}.tfplan

popd
