# Ansible Automation Controller

## Use

- Depends on [ODF with MCG](../odf/) for S3 type storage for Automation Hub
- Or use a CSI provider that offers RWX and modify `./operand/aap.yaml`
- Run `deploy.sh` to deploy operators and operands.

## Resources
- Service accounts for Ansible subs
    - <https://access.redhat.com/articles/7112649>
- Install Ansible on OpenShift
    - <https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/installing_on_openshift_container_platform/index>
- Ansible
    - https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform>
- Ansible Automation Platform CR
    - Examples: https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/installing_on_openshift_container_platform/appendix-operator-crs_appendix-operator-crs
- Automation Controller (AWX) Operator
    - https://github.com/ansible/awx-operator
- Automation Hub (Galaxy) Operator
    - https://github.com/pulp/pulp-operator
    - Docs: https://pulpproject.org/
    - Storage: https://github.com/pulp/pulp-operator/blob/main/docs/admin/guides/configurations/storage.md