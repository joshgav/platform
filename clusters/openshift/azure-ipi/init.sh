#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

azure_location=${AZURE_LOCATION:-northcentralus}
azure_group_name=${AZURE_GROUP_NAME:-openshift-ipi}
azure_app_name=${AZURE_APP_NAME:-openshift-ipi-admin}
azure_app_credentials_path=${HOME}/.azure/osServicePrincipal.json

az ad signed-in-user show &> /dev/null
if [[ $? != 0 ]]; then
    echo "[ERROR]: init script should be run as a regular user, not a service principal"
    return
fi

exists=$(az ad sp list --display-name ${azure_app_name} | jq 'length')
if [[ ${exists} == 0 ]]; then
    echo "[INFO]: creating new service principal \"${azure_app_name}\""
    sp=$(az ad sp create-for-rbac \
            --name "${azure_app_name}" \
            --role contributor \
            --scopes "/subscriptions/${AZURE_SUBSCRIPTION_ID}" \
            --output json)
    export AZURE_APP_ID=$(echo "${sp}" | jq -r '.appId')
    export AZURE_APP_SECRET=$(echo "${sp}" | jq -r '.password')
    az role assignment create \
        --assignee "${AZURE_APP_ID}" \
        --role "User Access Administrator"
    cat > ${azure_app_credentials_path} <<EOF
{
    "subscriptionId": "${AZURE_SUBSCRIPTION_ID}",
    "clientId":       "${AZURE_APP_ID}",
    "clientSecret":   "${AZURE_APP_SECRET}",
    "tenantId":       "${AZURE_TENANT_ID}"
}
EOF
else
    echo "[INFO]: using existing service principal \"${azure_app_name}\""
    sp=$(cat ${azure_app_credentials_path})
    export AZURE_APP_ID=$(echo "${sp}" | jq -r '.clientId')
    export AZURE_APP_SECRET=$(echo "${sp}" | jq -r '.clientSecret')
fi

echo "[INFO]: service principal metadata in use from ${azure_app_credentials_path}"
cat ${azure_app_credentials_path}
