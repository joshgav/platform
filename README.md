# devenv

Set up an OpenShift cluster and other goodies.

## Basic usage

1. Set secrets in `.env`.
1. Review cluster config in `cluster/install-config.yaml.tpl`.
1. Run `cluster/install.sh` to install cluster.

Cluster will be accessible at this URL:

- https://console-openshift-console.apps.<cluster_name>.<base_domain>/
- https://console-openshift-console.apps.aws-ipi.sandbox930.opentlc.com/

## Other services

- Run `aws/rhel.sh` to install a bastion host with RHEL 8.5.
- Run `aws/windows.sh` to install a host with Windows Server 2022.
    - Use commands in `windows/ad.ps1` to install and configure Active Directory.
- Run `services/rhsso.sh` to install the RHSSO operator and configure a realm and a client.
- Run `services/postgres.sh` to install CrunchyData PostgresQL Operator and a database instance.
- Run `services/apiserver.sh` to deploy a Spring Boot/Spring Web API server defined at https://github.com/joshgav/spring-apiserver
- Run `services/certmanager.sh` to deploy cert-manager and configure a cert from Let's Encrypt via ACME as the default ingress certificate
