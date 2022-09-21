# Kafka

1. Run `deploy.sh` to deploy Red Hat's AMQ streams operator based on [Strimzi](https://github.com/strimzi/strimzi-kafka-operator).
1. After the operator is deployed, a Kafka cluster will be deployed in the `kafka-cluster` namespace named `cluster-main`.

## Verify

Use [kcat](https://github.com/edenhill/kcat) as follows to verify functionality.

```bash
cluster_namespace=kafka-cluster
user=kafka-admin
password=$(oc get secrets kafka-user-${user} -n ${cluster_namespace} -ojson | jq -r '.data.password | @base64d')
# password=EWyOE5CXEfxA

cluster_namespace=kafka-cluster
cluster_name=cluster-main
app_namespace=quarkus-superheroes
topic=fights
user=fights
password=$(oc get secrets kafka-user-${user} -n ${cluster_namespace} -ojson | jq -r '.data.password | @base64d')
# password=AilTU5UdNzXS

## run kcat in container
kubectl run kcat -it --rm -n ${app_namespace} --image=docker.io/edenhill/kcat:1.7.1 --command -- \
    kcat -L -b ${cluster_name}-kafka-bootstrap.${cluster_namespace}:9092 -t ${topic} \
        -X security.protocol=SASL_PLAINTEXT -X sasl.mechanism=SCRAM-SHA-512 \
        -X sasl.username=${user} -X sasl.password=${password}

## produce messages
echo "message1" | kcat -P -b ${cluster_name}-kafka-bootstrap.${cluster_namespace}:9092 -t ${topic} -T \
    -X security.protocol=SASL_PLAINTEXT -X sasl.mechanism=SCRAM-SHA-512 \
    -X sasl.username=${user} -X sasl.password=${password}

## consume messages
kubectl run kcat -it --rm -n ${app_namespace} --image=docker.io/edenhill/kcat:1.7.1 --command -- \
    kcat -C -b ${cluster_name}-kafka-bootstrap.${cluster_namespace}:9092 -t ${topic} -o beginning -e \
        -X security.protocol=SASL_PLAINTEXT -X sasl.mechanism=SCRAM-SHA-512 \
        -X sasl.username=${user} -X sasl.password=${password}
```
