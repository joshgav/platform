# OpenShift cert-manager

## Notes
- Using the operator causes the builtin `cluster-admin` ClusterRole to be overwritten, breaking the cluster. So we're using `cmctl` still for now. See `deploy-operator.sh`.

## Docs
- https://docs.openshift.com/container-platform/4.10/security/cert_manager_operator/