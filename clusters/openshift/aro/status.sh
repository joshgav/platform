#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

az login --service-principal &> /dev/null \
    --tenant ${AZURE_TENANT_ID} \
    --username ${AZURE_PRINCIPAL_ID} \
    --password ${AZURE_PRINCIPAL_SECRET}
if [[ $? != 0 ]]; then
    echo "ERROR: failed to login"
    exit 2
fi

group_name=openenv-${AZURE_GROUP_ID}
vnet_name=aro-vnet-${AZURE_GROUP_ID}
cluster_name=aro-cluster-${AZURE_GROUP_ID}

az aro wait --created -g ${group_name} -n ${cluster_name} &> /dev/null
if [[ $? != 0 ]]; then
    echo "ERROR: failed to wait for ready cluster"
    exit 3
fi

cluster_info=$(az aro show --resource-group ${group_name} --name ${cluster_name} --output json)
cluster_creds=$(az aro list-credentials --resource-group ${group_name} --name ${cluster_name} --output json)
apiserver_url=$(echo "${cluster_info}" | jq -r '.apiserverProfile.url')
console_url=$(echo "${cluster_info}" | jq -r '.consoleProfile.url')
kubeadmin_password=$(echo "${cluster_creds}" | jq -r '.kubeadminPassword')

echo ""
echo "Cluster INFO"
echo "API server: ${apiserver_url}"
echo "Console: ${console_url}"
echo "kubeadmin password: ${kubeadmin_password}"

echo ""
echo "To login via the CLI run:"
echo "oc login --server ${apiserver_url} --username kubeadmin --password '${kubeadmin_password}'"
echo ""
