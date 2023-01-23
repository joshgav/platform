function login_azure {
    az login --service-principal \
        --username ${AZURE_PRINCIPAL_ID} \
        --password ${AZURE_PRINCIPAL_SECRET} \
        --tenant ${AZURE_TENANT_ID}

    az account set --subscription ${AZURE_SUBSCRIPTION_ID}
}

# in progress
function prep {
    local subscription_id=${1:-${AZURE_SUBSCRIPTION_ID}}
    local region=${2:-centralus}

    ## raise quota for Dsv3 and total vCPUs
    az extension add --upgrade --name quota
    az quota list --scope "subscriptions/${subscription_id}/providers/Microsoft.Compute/locations/${region}"
}