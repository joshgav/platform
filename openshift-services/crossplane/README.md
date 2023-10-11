# Crossplane

## Info

- Upstream provider packages: https://hub.docker.com/u/crossplanecontrib
- Configuration for RDS: https://github.com/upbound/configuration-rds
- Crossplane CLI: <https://releases.crossplane.io/stable/current/bin/linux_amd64/crossplane>

To delete an Azure service principal:

```bash
name=crossplane-system
sp_id=$(az ad sp list --display-name ${name} | jq -r '.[0].id')
if [[ -n "${sp_id}" ]]; then
    az ad sp delete --id ${sp_id}
fi
```