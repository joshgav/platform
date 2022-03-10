# devenv

Set up an OpenShift cluster using installer-provisioned infrastructure (IPI) in AWS.

Use:

1. Set secrets in `.env`.
1. Review cluster config in `install-config.yaml.tpl`.
1. Run `start.sh` to install cluster.

- Run `rhsso.sh` to install the RHSSO operator and configure a realm.
- Run `rhel-bastion.sh` to install a bastion host with RHEL 8.5.
- Run `windows-server.sh` to install a host with Windows Server 2022.
