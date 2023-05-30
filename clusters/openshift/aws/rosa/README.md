# Red Hat OpenShift on AWS (ROSA)

Provision [Red Hat OpenShift Service on AWS
(ROSA)](https://aws.amazon.com/rosa/) instances.

Begin from and manage clusters at <https://console.redhat.com/openshift>.

## Deploy cluster

1. Install [AWS CLI][], [rosa CLI][] and [jq](https://stedolan.github.io/jq/).
1. Set AWS access key secrets [as environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) or login.
1. Get a token for Red Hat's cloud console from <https://console.redhat.com/openshift/token/rosa/> and login with `rosa login --token="ey..."`.
1. Run `CLUSTER_NAME=rosa1 ./deploy.sh`.

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
