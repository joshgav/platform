#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

rosa login --token="${REDHAT_ACCOUNT_TOKEN}"

rosa create --yes ocm-role --admin --mode=auto --prefix "ManagedOpenShift"
rosa create --yes user-role --mode=auto --prefix="ManagedOpenShift"
rosa create --yes account-roles --mode=auto --prefix="ManagedOpenShift"

cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${CLUSTER_NAME}\") )")
if [[ -z ${cluster_json} ]]; then
    rosa create --yes cluster --cluster-name "${CLUSTER_NAME}" --sts --mode=auto --watch
    rosa create --yes admin --cluster "${CLUSTER_NAME}"
    cluster_json=$(rosa list clusters --output json | jq -r ".[] | select( .name | match(\"${CLUSTER_NAME}\") )")
fi

api_url=$(echo "${cluster_json}" | jq -r '.api.url')
console_url=$(echo "${cluster_json}" | jq -r '.console.url')

echo "INFO: API URL: ${api_url}"
echo "INFO: Console URL: ${console_url}"
