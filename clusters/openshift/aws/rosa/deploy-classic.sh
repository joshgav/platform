#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
cluster_name=${CLUSTER_NAME:-rosa1}

function create_cluster () {
    local cluster_name=${1}

    role_prefix=${cluster_name}

    echo "INFO: create ocm-role --admin"
    rosa create ocm-role --admin --yes --mode=auto

    echo "INFO: create user-role"
    rosa create user-role        --yes --mode=auto

    echo "INFO: create account-roles"
    rosa create account-roles --prefix ${role_prefix} --yes --mode=auto

    echo "INFO: create cluster"
    rosa create cluster --sts --cluster-name "${cluster_name}" --mode=auto --yes --watch
}

echo "INFO: Verify login to AWS"
aws sts get-caller-identity

echo "INFO: Verify login to RH OCM"
rosa login --env production \
    --token="${REDHAT_ACCOUNT_TOKEN}"
rosa whoami

echo "INFO: check for existing cluster named ${cluster_name}"
cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${cluster_name}\") )")
if [[ -n ${cluster_json} ]]; then
    echo "WARNING: found existing cluster named ${cluster_name}, skipping 'create' commands"
else
    echo "INFO: cluster not found, creating now"
    create_cluster "${cluster_name}"
fi

if [[ -n "${RECREATE_CLUSTER_ADMIN}" ]]; then
    echo "INFO: resetting admin user"
    # OR'ed with true so as not to exit on error if admin has not yet been created
    rosa delete admin --cluster "${cluster_name}" --yes || true
    rosa create admin --cluster "${cluster_name}" --yes
else
    echo "INFO: set RECREATE_CLUSTER_ADMIN=1 to reset cluster admin password"
fi

echo "INFO: getting cluster info"
cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${cluster_name}\") )")

api_url=$(echo "${cluster_json}" | jq -r '.api.url')
console_url=$(echo "${cluster_json}" | jq -r '.console.url')

echo "INFO: API URL: ${api_url}"
echo "INFO: Console URL: ${console_url}"
