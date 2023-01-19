function login_azure {
    az login --service-principal \
        --username ${AZURE_PRINCIPAL_ID} \
        --password ${AZURE_PRINCIPAL_SECRET} \
        --tenant ${AZURE_TENANT_ID}

    az account set --subscription ${AZURE_SUBSCRIPTION_ID}
}