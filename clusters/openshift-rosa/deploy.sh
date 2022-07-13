#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

source ${root_dir}/lib/requirements.sh
install_rosa_cli
install_aws_cli

rosa login --token="${REDHAT_ACCOUNT_TOKEN}"
rosa init --region=${AWS_REGION}

rosa create ocm-role --admin --yes --mode=auto --prefix "ManagedOpenShift"
rosa create user-role --yes
rosa create account-roles --yes

ocm_role_arn=$(aws iam list-roles --output json | jq -r '.Roles[] | select(.Arn | match("role/ManagedOpenShift-OCM-Role")) | .Arn')
user_role_arn=$(aws iam list-roles --output json | jq -r '.Roles[] | select(.Arn | match("role/ManagedOpenShift-User-.*-Role")) | .Arn')

rosa link ocm-role --role-arn "${ocm_role_arn}" --yes
rosa link user-role --role-arn "${user_role_arn}" --yes

cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${CLUSTER_NAME}\") )")
if [[ -z ${cluster_json} ]]; then
    rosa create cluster --cluster-name "${CLUSTER_NAME}" --sts --mode=auto --watch --yes
    rosa create admin --cluster "${CLUSTER_NAME}" --yes
    cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${CLUSTER_NAME}\") )")
fi

api_url=$(echo "${cluster_json}" | jq -r '.api.url')
console_url=$(echo "${cluster_json}" | jq -r '.console.url')

echo "INFO: API URL: ${api_url}"
echo "INFO: Console URL: ${console_url}"
