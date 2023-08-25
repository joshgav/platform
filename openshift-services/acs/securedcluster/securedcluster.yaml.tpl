apiVersion: platform.stackrox.io/v1alpha1
kind: SecuredCluster
metadata:
  name: stackrox-secured-cluster-services
  namespace: stackrox
spec:
  clusterName: ${cluster_name}
  centralEndpoint: ${central_endpoint}
  ## for local-cluster
  # centralEndpoint: central.stackrox.svc:443
  ## for external clusters
  # centralEndpoint: central-stackrox.apps.ipi.aws.joshgav.com:443