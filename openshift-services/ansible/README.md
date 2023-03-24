# Ansible Automation Controller

## Use

- Create an S3 bucket and set its access key ID and secret, endpoint and name in `.env`. (Required for Hub.)
- Run `deploy.sh` to deploy operators and operands.

## Resources
- Automation Controller (AWX) Operator: https://github.com/ansible/awx-operator
- Automation Hub (Galaxy) Operator: https://github.com/pulp/pulp-operator
- https://github.com/pulp/pulp-operator/blob/main/docs/configuring/storage.md#configure-aws-s3
- Reference Architecture: https://access.redhat.com/documentation/en-us/reference_architectures/2023/html/deploying_ansible_automation_platform_2_on_red_hat_openshift