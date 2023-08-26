# OpenShift Logging Subsystem

## Usage

1. Requires [noobaa](../noobaa/) in the cluster.
1. Run `./deploy.sh`

## For ELK

- After install you must configure indices in Kibana as documented here: <https://docs.openshift.com/container-platform/4.12/logging/cluster-logging-deploying.html#cluster-logging-visualizer-indices_cluster-logging-deploying>, illustrations follow:

    ![Kibana Create Index](./assets/kibana-create-index-01.png)
    ![Kibana Create Index](./assets/kibana-create-index-02.png)

## Resources

- https://docs.openshift.com/container-platform/4.12/logging/cluster-logging.html
- https://loki-operator.dev/
- https://loki-operator.dev/docs/api.md/
- https://github.com/grafana/loki/tree/main/operator
