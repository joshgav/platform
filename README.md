# devenv

Deliver Kubernetes clusters, services and apps.
NOTE: This repo is in development.

## Infrastructure

- clouds/libvirt
- clouds/aws
- clouds/azure
- clouds/ocp-upi (WIP)

## Kubernetes

- kubeadm (cluster/deploy.sh)
- OpenShift IPI for AWS (clouds/aws/install-openshift-ipi.sh)
- Azure Red Hat OpenShift (ARO) (clouds/azure/install-aro.sh)

## Services

- cert-manager (JetStack)
- keycloak (Red Hat)
- postgres (CrunchyData)
- acm (Red Hat)
- argocd (CNCF)
- che (Eclipse)
- opendatahub (Red Hat)
- crossplane (CNCF)
- emissary-ingress (Ambassador)
- freeipa (Red Hat)
- metallb
- active directory (Microsoft)
- crossplane with AWS
- kubernetes-dashboard (Kubernetes/CNCF)
- freeipa (Red Hat)
- instana (IBM)
- kafka (Strimzi)
- olm (Red Hat)
- tekton (CDF)

## Apps

- [spring-apiserver](https://github.com/joshgav/spring-apiserver)
- [podtato-head](https://github.com/podtato-head/podtato-head)

## Install local tools

```bash
sudo -E su

source ./lib/requirements.sh
export INSTALL_DIR=/usr/local/bin

install_cmctl
install_aws_cli
install_crossplane_cli
install_tkn_cli
install_argocd_cli
install_kubebuilder
install_operator_sdk

exit
```