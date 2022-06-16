#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

instance_name=${1:-"server"}
ami_id=${2:-"ami-0d9aeb8b30150a684"}
subnet_name=${3:-"sandbox-8496"}
ssh_key_path=${4:-"${root_dir}/ssh-key"}
instance_type=${5:-"r6i.4xlarge"}

# source ${this_dir}/amis.sh
# ami_id=${rhel_image_id}

# default_subnet_id=$(aws ec2 describe-subnets --output json --no-cli-pager | jq -r '.Subnets[] | select(.Tags[] | select(.Key == "catalog_item")) | .SubnetId')
echo "INFO: get subnet ID"
subnet_id=$(aws ec2 describe-subnets --output json | \
                      jq -r ".Subnets[] | select(.Tags[] | select(.Key == \"Name\" and (.Value | match(\"${subnet_name}\")))) | .SubnetId")
echo "INFO: get VPC ID"
vpc_id=$(aws ec2 describe-subnets --output json | \
                      jq -r ".Subnets[] | select(.Tags[] | select(.Key == \"Name\" and (.Value | match(\"${subnet_name}\")))) | .VpcId")
echo "INFO: get default SecurityGroup ID"
sg_id=$(aws ec2 describe-security-groups --output json | \
                  jq -r ".SecurityGroups[] | select((.GroupName == \"default\") and (.VpcId == \"${vpc_id}\")) | .GroupId")

echo "INFO: import key-pair"
if [[ ! -e "${ssh_key_path}/key" ]]; then
    # -N "" means no password
    ssh-keygen -f "${ssh_key_path}/key" -N ""
    chmod 400 "${ssh_key_path}/key"
fi

keypair_name=default
aws ec2 import-key-pair &> /dev/null \
    --key-name "${keypair_name}" \
    --public-key-material "fileb://${ssh_key_path}/key.pub"

{
    echo "INFO: run instance..."
    set -x
    aws ec2 run-instances --no-cli-pager \
        --image-id "${ami_id}" \
        --subnet-id "${subnet_id}" \
        --security-group-ids "${sg_id}" \
        --key-name "${keypair_name}" \
        --count 1 \
        --instance-type ${instance_type} \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${instance_name}}]" \
        --associate-public-ip-address
}
