#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

instance_name=${1:-windows-server}

source ${this_dir}/amis.sh

# default_subnet_id=$(aws ec2 describe-subnets --output json --no-cli-pager | jq -r '.Subnets[] | select(.Tags[] | select(.Key == "catalog_item")) | .SubnetId')
echo "INFO: get public subnet ID"
public_subnet_id=$(aws ec2 describe-subnets --output json | \
                      jq -r '.Subnets[] | select(.Tags[] | select(.Key == "Name" and (.Value | match("public-us-east-2a")))) | .SubnetId')
echo "INFO: get OpenShift VPC ID"
openshift_vpc_id=$(aws ec2 describe-subnets --output json | \
                      jq -r '.Subnets[] | select(.Tags[] | select(.Key == "Name" and (.Value | match("public-us-east-2a")))) | .VpcId')
echo "INFO: get default SecurityGroup ID"
default_sg_id=$(aws ec2 describe-security-groups --output json | \
                  jq -r ".SecurityGroups[] | select((.GroupName == \"default\") and (.VpcId == \"${openshift_vpc_id}\")) | .GroupId")

## TODO: programatically add a rule to default SG allowing SSH, WinRM, RDP

echo "INFO: import key-pair (if necessary)"
keypair_name=joshgav-rsa
aws ec2 import-key-pair &> /dev/null \
    --key-name "${keypair_name}" \
    --public-key-material "fileb://${OPENSHIFT_SSH_PUBLIC_KEY_PATH}"

{
    echo "INFO: run instance..."
    set -x
    aws ec2 run-instances --no-cli-pager \
        --image-id "${windows_latest_image_id}" \
        --subnet-id "${public_subnet_id}" \
        --security-group-ids "${default_sg_id}" \
        --key-name "${keypair_name}" \
        --count 1 \
        --instance-type t3.large \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${instance_name}}]" \
        --associate-public-ip-address
}
