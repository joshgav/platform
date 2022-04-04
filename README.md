# devenv

Set up OpenShift clusters and services.

## AWS IPI

1. Set secrets in `.env`.
1. Review cluster config in `aws/install-config.yaml.tpl`.
1. Run `aws/install-ipi.sh` to install cluster.

Cluster will be accessible at this URL:

- https://console-openshift-console.apps.<cluster_name>.<base_domain>/
- https://console-openshift-console.apps.aws-ipi.sandbox930.opentlc.com/

## Azure ARO

1. Set secrets in `.env`.
1. Run `azure/install-aro.sh` to install cluster and get kubeadmin binding.

## Other services

- Run `aws/rhel.sh` to install a bastion host with RHEL 8.5.
- Run `aws/windows.sh` to install a host with Windows Server 2022.
    - Use commands in `windows/ad.ps1` to install and configure Active Directory.
- Run `services/certmanager.sh` to deploy cert-manager and configure a cert from Let's Encrypt via ACME as the default ingress certificate
- Run `services/rhsso.sh` to install the RHSSO operator and configure a realm and a client.
- Run `services/postgres.sh` to install CrunchyData PostgresQL Operator and a database instance.
- Run `services/apiserver.sh` to deploy a Spring Boot/Spring Web API server defined at https://github.com/joshgav/spring-apiserver
