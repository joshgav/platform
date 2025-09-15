## HCP

## Docs
- Main: <https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/hosted_control_planes/index>
- Upstream: <https://hypershift.pages.dev/>

## For all HCP clusters
- Label each node with `hypershift.openshift.io/control-plane: true`
- Allow wildcard addresses:
    ```bash
    oc patch ingresscontroller -n openshift-ingress-operator default \
    --type=json \
    -p '[{ "op": "add", "path": "/spec/routeAdmission", "value": {wildcardPolicy: "WildcardsAllowed"}}]'
    ```

## Scale a NodePool to Zero

- https://hypershift.pages.dev/how-to/automated-machine-management/scale-to-zero-dataplane/
- `oc annotate -n clusters-hcp-kubevirt machines.cluster.x-k8s.io --all "machine.cluster.x-k8s.io/exclude-node-draining="`
- `oc get machines.cluster.x-k8s.io -n clusters-hcp-kubevirt`

### For Kubevirt HCP Cluster
- Create a credential for an on-premises env: <https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.13/html/clusters/cluster_mce_overview#creating-a-credential-for-an-on-premises-environment>

### For Bare Metal HCP Cluster
- Enable Central Infrastructure Management (CIM): 