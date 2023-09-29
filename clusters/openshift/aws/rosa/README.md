# Red Hat OpenShift on AWS (ROSA)

Provision [Red Hat OpenShift Service on AWS (ROSA)](https://console.aws.amazon.com/rosa/home) instances.

Enable in AWS at <https://console.aws.amazon.com/rosa/home#/get-started>

Enable in Red Hat at <https://console.redhat.com/connect/aws>

Follow guide at <https://docs.aws.amazon.com/ROSA/latest/userguide/getting-started-hcp.html>

Manage clusters at <https://console.redhat.com/openshift>.

## Deploy ROSA cluster

1. Install [AWS CLI][], [rosa CLI][] and [jq](https://stedolan.github.io/jq/).
1. Set AWS access key secrets [as environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) or login.
1. Get a token for Red Hat's cloud console from <https://console.redhat.com/openshift/token/rosa/> and login with `rosa login --token="ey..."`.
1. For a ROSA/Classic cluster run `./deploy.sh`; for a ROSA/HCP cluster run `./deploy-hcp.sh`.

Be sure to note the cluster-admin password printed at the end. Put it in the `.env` file in this dir.

[AWS CLI]: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
[rosa CLI]: https://console.redhat.com/openshift/downloads#tool-rosa

## Use cluster

`deploy.sh` will provision IAM roles and a cluster; and publish API and Console
URLs and username and password to stdout. Use the URLs and credentials to login
with the `oc` CLI as follows:

```bash
source .env && \
   oc login "${CLUSTER_API_URL}" --username cluster-admin --password "${CLUSTER_ADMIN_PASSWORD}"

## for example:
oc login https://api.rosa1.n9km.p1.openshiftapps.com:6443 \
   --username cluster-admin --password HRppn-5IKNZ-oZHQh-XbbQ2
```

## Info

- [Create ROSA cluster - Red Hat Console](https://console.redhat.com/openshift/create/rosa/getstarted?source=aws)
- [Create ROSA cluster - AWS docs](https://docs.aws.amazon.com/ROSA/latest/userguide/getting-started-sts-auto.html)
- [Create ROSA cluster - Red Hat docs](https://docs.openshift.com/rosa/rosa_hcp/rosa-hcp-sts-creating-a-cluster-quickly.html)
- HCP Quick start: https://docs.openshift.com/rosa/rosa_hcp/rosa-hcp-sts-creating-a-cluster-quickly.html
- HCP: https://docs.openshift.com/container-platform/4.13/hosted_control_planes/index.html
- Terraform for VPC: https://github.com/openshift-cs/terraform-vpc-example
