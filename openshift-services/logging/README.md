# OpenShift Logging Subsystem

## For Lokistack and Vector

- Provision an S3 bucket and specify its URL, access key ID and secret in `.env`.
- In `deploy.sh` set `logging_stack=loki` then run `./deploy.sh`
- Copy TLS secret from `minio-tenant-1` tenant namespace, secret `tenant-1-tls` to a ConfigMap in `openshift-logging` namespace named `tenant-1-tls` as key name `tls.crt`.
- Enable the console plugin in the OpenShift ClusterLogging resource.

## For ELK

- In `deploy.sh` set `logging_stack=elk`
- After install you must configure indices in Kibana as documented here: <https://docs.openshift.com/container-platform/4.12/logging/cluster-logging-deploying.html#cluster-logging-visualizer-indices_cluster-logging-deploying>, illustrations follow:

    ![Kibana Create Index](./assets/kibana-create-index-01.png)
    ![Kibana Create Index](./assets/kibana-create-index-02.png)

## Resources

- https://docs.openshift.com/container-platform/4.12/logging/cluster-logging.html
- https://loki-operator.dev/
- https://loki-operator.dev/docs/api.md/
- https://github.com/grafana/loki/tree/main/operator
