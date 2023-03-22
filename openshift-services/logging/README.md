# OpenShift Logging Subsystem

## For Lokistack and Vector

NOTE: this is a work in progress!

- In `deploy.sh` set `logging_stack=loki`
- Depends on minio or ODF to provide buckets.
- Currently I copied the access key ID and secret manually.
- When using minio make sure the TLS cert for the minio tenant is recognized by the Lokistack.
- Enable the console plugin in the OpenShift ClusterLogging resource.

## For ELK

- In `deploy.sh` set `logging_stack=elk`
- After install you must configure indices in Kibana as documented here: <https://docs.openshift.com/container-platform/4.12/logging/cluster-logging-deploying.html#cluster-logging-visualizer-indices_cluster-logging-deploying>

## Resources

- https://docs.openshift.com/container-platform/4.12/logging/cluster-logging.html
- https://loki-operator.dev/
- https://github.com/grafana/loki/tree/main/operator
