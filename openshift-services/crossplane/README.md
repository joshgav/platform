# Crossplane

- Deploy Crossplane and official providers for AWS and Azure using `deploy.sh`.
- This uses these providers:
    - https://marketplace.upbound.io/providers/upbound/provider-azure
    - https://marketplace.upbound.io/providers/upbound/provider-aws
- Deploy a custom composition using `deploy-resources.sh`
    - Configuration for this composition derived from <https://github.com/upbound/configuration-rds>

## Tips:

- To delete an Azure service principal:
    ```bash
    sp_name=crossplane-system
    sp_id=$(az ad sp list --display-name ${sp_name} | jq -r '.[0].id')
    if [[ -n "${sp_id}" ]]; then az ad sp delete --id ${sp_id}; fi
    ```