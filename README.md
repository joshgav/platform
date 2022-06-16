# devenv

Deliver Kubernetes clusters, services and apps.
NOTE: This repo is in development. For one, more parameterization is needed.

## Infrastructure providers

One of:

- libvirt
- AWS
- Azure

## Cluster types

One of:

- OpenShift IPI for AWS
- OpenShift on Azure (ARO)
- Kubernetes via kubeadm

## Services

- cert-manager (JetStack)
- keycloak
- postgres (Crunchy)
- acm (Red Hat)
- argocd
- che (Eclipse)
- opendatahub (Red Hat)
- emissary-ingress (Ambassador)
- freeipa (LDAP/KRB)
- metallb
- active directory (Microsoft)
- crossplane with AWS
- kubernetes-dashboard
- freeipa (Red Hat)
- instana (IBM)
- kafka (Strimzi)
- olm (Red Hat)
- tekton

## Apps

- spring-apiserver