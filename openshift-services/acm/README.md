# Advanced Cluster Manager

- Deploy ACM using `./deploy-acm.sh`
- Deploy a cluster with a hosted control planes using `./deploy-hcp-cluster.sh`
- Deploy MultiCluster Observability using `./deploy-observability.sh`. It requires [noobaa](../noobaa/).

## ArgoCD Integration
- https://argocd-applicationset.readthedocs.io/en/stable/Generators-Cluster-Decision-Resource/

## Resources
- Docs: https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.8/html-single/clusters/index#hosted-control-planes-intro
- Control plane: https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.8/html-single/clusters/index#hosting-service-cluster-configure-aws
- Worker nodes: https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.8/html-single/clusters/index#hosted-control-planes-manage-aws

## Policy Templates
- Template functions: <https://open-cluster-management.io/concepts/policy/#templating-functions>
- Old blog on templates: <https://cloud.redhat.com/blog/applying-policy-based-governance-at-scale-using-templates>
- Doc: <https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.8/html/governance/governance#template-processing>