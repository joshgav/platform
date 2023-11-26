#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source ${this_dir}/init.sh

function create_cluster () {
    local cluster_name=${1}
    local AWS_REGION=${2:-${AWS_REGION}}

    echo "INFO: deploy VPC via AWS CLI"
    ${this_dir}/deploy-vpc-cli.sh ${cluster_name} ${AWS_REGION}

    echo "INFO: getting subnet IDs by tag:Name"
    subnets_public=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${cluster_name}-public" --query "Subnets[].SubnetId" --output json)
    subnets_private=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${cluster_name}-private" --query "Subnets[].SubnetId" --output json)
    export SUBNET_IDS=$(echo "${subnets_public}" | jq -r ". + ${subnets_private} | join(\",\")")
    echo "INFO: Subnet IDs: ${SUBNET_IDS}"

    echo "INFO: apply account-roles"
    rosa create account-roles --hosted-cp --force-policy-creation --prefix ${cluster_name} --yes --mode=auto --interactive=false

    echo "INFO: apply OIDC configs"
    oidc_config_id=$(rosa list oidc-config -ojson | jq -r '.[0].id')
    if [[ "null" == "${oidc_config_id}" ]]; then
        echo "INFO: oidc-config not found, creating one"
        rosa create oidc-config --yes --mode=auto
        oidc_config_id=$(rosa list oidc-config -ojson | jq -r '.[0].id')
    fi
    echo "INFO: using oidc-config with ID ${oidc_config_id}"

    echo "INFO: gather account role ARNs"
    installer_role_arn=$(rosa list account-roles --output json | jq -r ".[] | select(.RoleName == \"${cluster_name}-HCP-ROSA-Installer-Role\") | .RoleARN")
    worker_role_arn=$(rosa list account-roles --output json | jq -r ".[] | select(.RoleName == \"${cluster_name}-HCP-ROSA-Worker-Role\") | .RoleARN")
    support_role_arn=$(rosa list account-roles --output json | jq -r ".[] | select(.RoleName == \"${cluster_name}-HCP-ROSA-Support-Role\") | .RoleARN")
    echo -e "INFO: using role ARNs:\n\tinstaller_role_arn ${installer_role_arn}\n\tworker_role_arn ${worker_role_arn}\n\tsupport_role_arn ${support_role_arn}"

    echo "INFO: apply operator-roles"
    rosa create operator-roles --hosted-cp --mode=auto --yes \
        --force-policy-creation \
        --installer-role-arn "${installer_role_arn}" \
        --oidc-config-id ${oidc_config_id} \
        --prefix ${cluster_name}

    echo "INFO: create cluster"
    rosa create cluster --cluster-name "${cluster_name}" --mode=auto --yes --watch \
        --sts --hosted-cp --region ${AWS_REGION} \
        --role-arn ${installer_role_arn} \
        --worker-iam-role ${worker_role_arn} \
        --support-role-arn ${support_role_arn} \
        --operator-roles-prefix ${cluster_name} \
        --oidc-config-id ${oidc_config_id} \
        --compute-machine-type "${instance_type}" \
        --subnet-ids "${SUBNET_IDS}" \
        --enable-autoscaling --min-replicas 3 --max-replicas 36 \
        --create-admin-user
}

if [[ -n ${cluster_json} ]]; then
    echo "WARNING: found existing cluster named ${cluster_name}, skipping 'create' commands"
else
    echo "INFO: cluster not found, creating now"
    create_cluster "${cluster_name}"
    echo "INFO: updating cluster info"
    export cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${cluster_name}\") )")
    echo -e "INFO: updated cluster info:\n$(echo ${cluster_json} | jq)"
fi

${this_dir}/status.sh ${cluster_name} ${AWS_REGION}
