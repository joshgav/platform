# OpenShift on AWS with User-Provisioned Infrastructure (UPI)

Provision OpenShift clusters. User installs infrastructure.

## Deploy cluster

`deploy.sh` deploys a cluster as follows:

1. Generate OpenShift manifests, adjust as required and embed into CoreOS Ignition configs.
1. Orchestrate a series of CloudFormation stack deployments as described
   [here](https://github.com/openshift/installer/tree/master/upi/aws/cloudformation).
1. Finalize cluster installation using `openshift-install wait-for`.

Unlike installer-provisioned infrastructure, with UPI the human installer must
configure machines to initialize themselves from CoreOS Ignition configs.

To destroy the cluster, run `destroy.sh` to delete the created CloudFormation
stacks in reverse order of creation.

## Use cluster

As with installer-provisioned infrastructure (IPI), credentials and URLs are
written to stdout by `openshift-install wait-for install-complete`.
Alternatively, find config files in `_workdir/auth`.

## More resources

- [Starting doc](https://docs.openshift.com/container-platform/4.10/installing/installing_aws/installing-aws-user-infra.html)
- [Troubleshooting installations](https://docs.openshift.com/container-platform/4.10/support/troubleshooting/troubleshooting-installations.html)
- CFN templates for AWS UPI: <https://github.com/openshift/installer/tree/master/upi/aws/cloudformation>
    - [Official docs](https://docs.openshift.com/container-platform/4.10/installing/installing_aws/installing-aws-user-infra.html#installation-cloudformation-vpc_installing-aws-user-infra)
    - [GitHub docs](https://github.com/openshift/installer/blob/master/docs/user/aws/install_upi.md)
