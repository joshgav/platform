# Walkthrough Script

This is a walkthrough of how to prepare a cluster and platform capabilities, then install applications.

## Base capabilities
1. Install OpenShift to AWS via IPI ([link](../clusters/openshift/aws/ipi/))
1. Install cert-manager to provision ACME certificates from Let's Encrypt for ingress ([link](../openshift-services/cert-manager/))
1. Configure AlertManager to forward events to Slack ([link](../openshift-services/setup/alertmanager/))
1. Configure user authentication via Google OIDC ([link](../openshift-services/setup/oidc-google/))
1. Configure user authentication via Keycloak and GitHub OIDC ([link](../openshift-services/keycloak/deploy-cluster-iam.sh))
1. Configure user workload monitoring (Prometheus) in OpenShift ([link](../openshift-services/setup/monitoring/))
1. Configure machine autoscalers ([link](../openshift-services/setup/autoscaler/))
1. Install Minio to provide S3-compatible buckets ([link](../openshift-services/minio/))
    1. Create a bucket named `loki-data` to hold logging entries.
1. Install OpenShift logging stack ([link](../openshift-services/logging/))
1. Install OpenShift tracing stack ([link](../openshift-services/opentelemetry/))
1. Install Cloud-Native Postgres operator ([link](../openshift-services/postgres/))
1. Install OpenShift GitOps stack ([link](../openshift-services/gitops/))
1. Install OpenShift Pipelines ([link](../openshift-services/pipelines/))
    1. Connect Pipelines as Code to application repos.
1. Install Noobaa ([link](../openshift-services/noobaa/))
1. Install Quay ([link](../openshift-services/quay/))
1. Install applications
    1. Backstage ([link](https://github.com/joshgav/backstage-on-openshift))
    1. Spring API server ([link](https://github.com/joshgav/spring-apiserver))

## More capabilities
1. Install APIcurio operator ([link](../openshift-services/apicurio/))
1. Install Strimzi operator ([link](../openshift-services/kafka/))
1. Install MongoDB operator ([link](../openshift-services/mongodb/))
1. Install Knative ([link](../openshift-services/serverless/))
1. TODO: move superheroes to CNPG DB ([link](../openshift-services/postgres/))
1. Install applications
    1. Quarkus Superheroes ([link](../apps/superheroes/))
