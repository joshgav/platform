#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
source ${this_dir}/helpers.sh

instance_name=${1:-instance01}
# RHEL 8.6
ami_id=ami-073c570ae7a0977cb
vpc_stack_name=vpc1
instance_stack_name=${instance_name}

aws cloudformation describe-stacks --stack-name ${vpc_stack_name} &> /dev/null
if [[ $? == 254 ]]; then
    echo "INFO: creating cfn stack ${vpc_stack_name}"
    aws cloudformation create-stack --stack-name "${vpc_stack_name}" \
        --template-body "$(cat ${root_dir}/infrastructure/aws/templates/vpc.yaml)"
else
    echo "INFO: using existing cfn stack ${vpc_stack_name}"
fi

## await stack creation
done=false
while ! ${done}; do
    vpc_status=$(aws cloudformation describe-stacks --stack-name ${vpc_stack_name} --output json | \
        jq -r '.Stacks[].StackStatus')
    if [[ "${vpc_status}" == 'CREATE_COMPLETE' ]]; then
        done=true
    fi
done

# VPC stack outputs
stack_outputs=$(aws cloudformation describe-stacks --stack-name "${vpc_stack_name}" --output json | jq '.Stacks[0].Outputs')
vpc_id=$(echo "${stack_outputs}" | jq -r ".[] | select(.OutputKey == \"VpcId\") | .OutputValue")
subnet_id=$(echo "${stack_outputs}" | jq -r ".[] | select(.OutputKey == \"SubnetId\") | .OutputValue")

aws cloudformation describe-stacks --stack-name shared &> /dev/null
if [[ $? == 254 ]]; then
    echo "INFO: creating cfn stack shared"
    aws cloudformation create-stack --stack-name shared \
        --template-body "$(cat ${root_dir}/infrastructure/aws/templates/shared.yaml)" \
        --parameters "ParameterKey=VpcId,ParameterValue=${vpc_id}"
else
    echo "INFO: using existing cfn stack shared"
fi

## await stack creation
done=false
while ! ${done}; do
    status=$(aws cloudformation describe-stacks --stack-name shared --output json | \
        jq -r '.Stacks[].StackStatus')
    if [[ "${status}" == 'CREATE_COMPLETE' ]]; then
        done=true
    else
        echo "INFO: awaiting stack creation..."
        sleep 2
    fi
done


security_group_id=$(sg_id_by_name Base)

aws cloudformation describe-stacks --stack-name ${instance_stack_name} &> /dev/null
if [[ $? == 254 ]]; then
    echo "INFO: creating cfn stack ${instance_stack_name}"
    aws cloudformation create-stack --stack-name ${instance_stack_name} \
        --template-body "$(cat ${root_dir}/infrastructure/aws/templates/ec2-instance.yaml)" \
        --parameters "ParameterKey=SubnetId,ParameterValue=${subnet_id}" \
                     "ParameterKey=AMI,ParameterValue=${ami_id}" \
                     "ParameterKey=SecurityGroupId,ParameterValue=${security_group_id}" \
                     "ParameterKey=InstanceName,ParameterValue=${instance_name}"
else
    echo "INFO: using existing cfn stack ${instance_stack_name}"
fi
