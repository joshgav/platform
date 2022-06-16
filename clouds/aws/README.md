# AWS

## OpenShift IPI - AWS

1. Set secrets in `.env`.
1. Review cluster config in `aws/install-config.yaml.tpl`.
1. Run `aws/install-openshift-ipi.sh` to install cluster.

Cluster will be accessible at this URL:

- https://console-openshift-console.apps.<cluster_name>.<base_domain>/
- https://console-openshift-console.apps.aws-ipi.sandbox930.opentlc.com/

## Others

- Run `aws/install-rhel-instance.sh` to install a bastion host with RHEL 8.5.
- Run `aws/install-windows-instance.sh` to install a host with Windows Server 2022.