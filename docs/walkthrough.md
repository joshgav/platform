# Walkthrough Script

This is a walkthrough of how to prepare a cluster and various capabilities, then install applications.

## Base capabilities
1. Install OpenShift to AWS via IPI ([link](../clusters/openshift/aws/ipi/))
1. Install cert-manager and replace ingress certs with trusted ones ([link](../openshift-services/cert-manager/))
1. (Optional) Configure user authentication via Google OIDC ([link](../openshift-services/setup/oidc-google/))
1. (Optional) Configure user authentication via Keycloak and GitHub OIDC ([link](../openshift-services/keycloak/deploy-cluster-iam.sh))
1. Configure machine autoscalers ([link](../openshift-services/setup/autoscaler/))
1. Install noobaa operator and system ([link](../openshift-services/noobaa/))

## Observability capabilities
1. Configure AlertManager to forward events to Slack ([link](../openshift-services/setup/alertmanager/))
1. Configure user workload monitoring (Prometheus) in OpenShift ([link](../openshift-services/setup/monitoring/))
1. Install OpenShift logging stack ([link](../openshift-services/logging/))
1. Install OpenShift tracing stack ([link](../openshift-services/opentelemetry/))

## Build capabilities
1. Install Quay operator and registry ([link](../openshift-services/quay/))
1. Install OpenShift GitOps stack ([link](../openshift-services/gitops/))
1. Install OpenShift Pipelines ([link](../openshift-services/pipelines/))
1. Connect Pipelines as Code to application repos.

## More capabilities
1. Install Cloud-Native Postgres operator ([link](../openshift-services/postgres/))
1. Install Strimzi operator ([link](../openshift-services/kafka/))
1. Install APIcurio operator ([link](../openshift-services/apicurio/))
1. Install MongoDB operator ([link](../openshift-services/mongodb/))
1. Install Knative ([link](../openshift-services/serverless/))

## Applications
1. Backstage ([link](https://github.com/joshgav/backstage-on-openshift))
1. Spring API server ([link](https://github.com/joshgav/spring-apiserver))
1. Quarkus Superheroes ([link](../apps/superheroes/))
    1. TODO: move superheroes to CNPG DB ([link](../openshift-services/postgres/))
