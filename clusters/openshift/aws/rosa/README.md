# Red Hat OpenShift on AWS (ROSA)

Provision [Red Hat OpenShift Service on AWS (ROSA)](https://console.aws.amazon.com/rosa/home) instances.

Enable in AWS at <https://console.aws.amazon.com/rosa/home#/get-started>

Enable in Red Hat at <https://console.redhat.com/connect/aws>

Follow guide at <https://docs.aws.amazon.com/ROSA/latest/userguide/getting-started-hcp.html>

Manage clusters at <https://console.redhat.com/openshift>.

## Deploy ROSA cluster

1. Install [AWS CLI][], [rosa CLI][] and [jq](https://stedolan.github.io/jq/).
1. Set AWS access key secrets
   - [as environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
   - or in `.env`
1. Get a token for Red Hat's cloud console from <https://console.redhat.com/openshift/token/rosa/> and
   - login with `rosa login --token="ey..."`
   - or set in `.env`
1. Create the cluster:
   - for a ROSA/Classic cluster run `./deploy-classic.sh <cluster_name> <aws_region>`, e.g. `./deploy-classic.sh rosa1 us-east-1`
   - for a ROSA/HCP cluster run `./deploy-hcp.sh <cluster_name> <aws_region>`, e.g. `./deploy-hcp.sh rosa2 eu-central-1`

Be sure to note the cluster-admin password printed at the end.

[AWS CLI]: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
[rosa CLI]: https://console.redhat.com/openshift/downloads#tool-rosa

## Info

- [Create ROSA cluster - Red Hat Console](https://console.redhat.com/openshift/create/rosa/getstarted?source=aws)
- [Create ROSA cluster - AWS docs](https://docs.aws.amazon.com/ROSA/latest/userguide/getting-started-sts-auto.html)
- [Create ROSA cluster - Red Hat docs](https://docs.openshift.com/rosa/rosa_hcp/rosa-hcp-sts-creating-a-cluster-quickly.html)
- HCP Quick start: https://docs.openshift.com/rosa/rosa_hcp/rosa-hcp-sts-creating-a-cluster-quickly.html
- HCP: https://docs.openshift.com/container-platform/4.13/hosted_control_planes/index.html
- Terraform for VPC: https://github.com/openshift-cs/terraform-vpc-example
- Check instance types:
   ```bash
   rosa list instances-types

   aws ec2 describe-instance-type-offerings --location-type availability-zone \
      --filters "Name=location,Values=${aws_az}" --region ${aws_region} --output text
   ```
- Deploy VPC and subnets using Terraform:
   ```bash
   echo "INFO: deploying VPC using Terraform"
   ${this_dir}/deploy-vpc-tf.sh
   pushd ${this_dir}/tf
   export SUBNET_IDS=$(terraform output -raw cluster-subnets-string)
   popd
   ```