#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

kubespray_dir=${this_dir}/kubespray
mkdir -p ${kubespray_dir}

## ensure key pair exists in region
aws ec2 describe-key-pairs --key-names devenv &> /dev/null
if [[ $? == 254 ]]; then
    echo "INFO: creating default key pair"
    aws ec2 import-key-pair --key-name devenv \
        --public-key-material fileb://${root_dir}/.ssh/id_rsa.pub
fi

## clone kubespray for ease of use of contrib files
if [[ ! -e "${kubespray_dir}/Makefile" ]]; then
    git clone https://github.com/kubernetes-sigs/kubespray.git ${kubespray_dir}
fi

## copy overrides
cp ${this_dir}/variables_override.tf ${kubespray_dir}/contrib/terraform/aws

## init module
terraform -chdir=${kubespray_dir}/contrib/terraform/aws init \
    -var-file="${this_dir}/terraform.tfvars"

## apply module
terraform -chdir=${kubespray_dir}/contrib/terraform/aws apply ${TF_DESTROY:+'-destroy'} -auto-approve -input=false \
    -state=${this_dir}/aws.tfstate \
    -var-file="${this_dir}/terraform.tfvars" \
    -var="AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
    -var="AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
    -var="AWS_SSH_KEY_NAME=devenv" \
    -var="AWS_DEFAULT_REGION=us-east-2"
