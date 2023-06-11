#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

cluster_name=${CLUSTER_NAME:-rosa1}

echo "INFO: Verify login to AWS"
aws sts get-caller-identity

# https://console.redhat.com/openshift/token/rosa/
echo "INFO: Verify login to RH OCM"
# re `--env` see https://github.com/openshift/rosa/blob/master/pkg/ocm/config.go
# rosa login --env production --token="${REDHAT_ACCOUNT_TOKEN}"
rosa login --env staging --token="${REDHAT_ACCOUNT_TOKEN}"
rosa whoami

echo "INFO: check for existing cluster named ${cluster_name}"
cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${cluster_name}\") )")
if [[ -n ${cluster_json} ]]; then
    echo "WARNING: found existing cluster named ${cluster_name}, exiting"
    exit 3
else
    echo "INFO: cluster not found, creating now"
fi

role_prefix=${cluster_name}
# bind RHOCM to current AWS account
rosa create ocm-role --admin --yes --mode=auto
# bind RHOCM user to current AWS account
rosa create user-role        --yes --mode=auto
# create OpenShift-related roles
# rosa delete account-roles --hosted-cp --prefix=${role_prefix} --yes --mode=auto
## TODO: use `rosa upgrade account-roles` ?
rosa create account-roles --hosted-cp --prefix=${role_prefix} --yes --mode=auto --managed

oidc_config_id=$(rosa list oidc-config -ojson | jq -r '.[0].id')
if [[ "null" == "${oidc_config_id}" ]]; then
    echo "INFO: oidc-config not found, creating one"
    rosa create oidc-config --yes --mode=auto
    oidc_config_id=$(rosa list oidc-config -ojson | jq -r '.[0].id')
fi
echo "INFO: using oidc-config with ID ${oidc_config_id}"

## TODO: automate getting installer role ARN
installer_role=$(rosa list account-roles --output json | jq -r '.[] | select(.RoleType == "Installer")')
installer_role_arn=$(echo "${installer_role}" | jq -r '.RoleARN')

rosa create operator-roles --mode=manual --yes \
    --hosted-cp \
    --installer-role-arn "${installer_role_arn}" \
    --oidc-config-id ${oidc_config_id} \
    --prefix ${role_prefix}

# pushd ${this_dir}/tf
# terraform plan -out rosa.plan -var aws_region=${AWS_REGION} -var cluster_name=${cluster_name}
# terraform apply rosa.plan
# public_subnet_id=$(terraform output -raw cluster-public-subnet)
# private_subnet_id=$(terraform output -raw cluster-private-subnet)
# popd

# TODO: create VPC and subnets
#       for now, you must create them manually and name the VPC the same as the cluster
source ${root_dir}/lib/aws.sh
subnets=($(subnets_in_vpc ${cluster_name}-vpc))
subnets_for_command=$(IFS=,; echo "${subnets[*]}")

rosa create cluster --cluster-name "${cluster_name}" --mode=auto --yes \
    --sts \
    --hosted-cp \
    --operator-roles-prefix ${role_prefix} \
    --subnet-ids "${subnets_for_command}" \
    --oidc-config-id ${oidc_config_id}

rosa create admin --cluster "${cluster_name}" --yes

cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${cluster_name}\") )")

api_url=$(echo "${cluster_json}" | jq -r '.api.url')
console_url=$(echo "${cluster_json}" | jq -r '.console.url')

echo "INFO: API URL: ${api_url}"
echo "INFO: Console URL: ${console_url}"
