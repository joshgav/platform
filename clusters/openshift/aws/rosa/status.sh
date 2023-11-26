#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source ${this_dir}/init.sh

if [[ -z ${cluster_json} ]]; then
    echo "WARNING: cluster ${cluster_name} not found"
    exit 3
fi

if [[ -n "${RECREATE_CLUSTER_ADMIN}" ]]; then
    echo "INFO: resetting admin user"
    # OR'ed with true so as not to exit on error if admin has not yet been created
    rosa delete admin --cluster "${cluster_name}" --yes || true
    rosa create admin --cluster "${cluster_name}" --yes
else
    rosa describe admin --cluster ${cluster_name}
    echo "INFO: set RECREATE_CLUSTER_ADMIN=1 to reset cluster admin password"
fi

api_url=$(echo "${cluster_json}" | jq -r '.api.url')
console_url=$(echo "${cluster_json}" | jq -r '.console.url')

echo "INFO: API URL: ${api_url}"
echo "INFO: Console URL: ${console_url}"
