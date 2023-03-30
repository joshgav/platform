#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

kubespray_dir=${this_dir}/kubespray
mkdir -p ${kubespray_dir}

keypair_name=kubespray

## ensure key pair exists in region
aws ec2 describe-key-pairs --key-names ${keypair_name} &> /dev/null
if [[ $? == 254 ]]; then
    echo "INFO: creating default key pair"
    aws ec2 import-key-pair --key-name ${keypair_name} \
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
    -var="AWS_SSH_KEY_NAME=${keypair_name}" \
    -var="AWS_DEFAULT_REGION=${AWS_REGION}"
