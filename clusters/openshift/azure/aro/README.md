## Azure ARO

1. Set secrets in `.env` here and/or in the root.
1. Run `deploy.sh` to install cluster and get kubeadmin binding.

Later, run `status.sh` to check on the cluster and get the kubeadmin binding.

### Resources

- Microsoft Learning: <https://learn.microsoft.com/en-us/azure/openshift/>
- Roadmap (GitHub): <https://github.com/Azure/OpenShift/projects/1>
- Update pull secret to connect cluster to [console.redhat.com](https://console.redhat.com/)
    - https://access.redhat.com/articles/6958394
    - https://learn.microsoft.com/en-us/azure/openshift/howto-add-update-pull-secret
- Create a service principal to deploy ARO: <https://learn.microsoft.com/en-us/azure/openshift/howto-create-service-principal>
- Configure cluster user authn with AAD: <https://learn.microsoft.com/en-us/azure/openshift/configure-azure-ad-cli>
- Deploy an ARO cluster using ARM templates: <https://learn.microsoft.com/en-us/azure/openshift/quickstart-openshift-arm-bicep-template?pivots=aro-arm>
- Schedule cluster upgrades: <https://learn.microsoft.com/en-us/azure/openshift/howto-upgrade>