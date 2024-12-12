# OpenShift cert-manager

- Run `deploy-operator.sh` to just deploy the openshift-cert-manager-operator via OLM.
- Run `deploy.sh` to deploy the operator and then configurations for AWS and OpenShift.
    - Patches to the `IngressController` and `APIServer` resources are executed via imperative commands at the end of the script.

Modifications would be required to support other infrastructure providers than AWS and Route53.

## Docs

- https://docs.openshift.com/container-platform/4.11/security/cert_manager_operator/