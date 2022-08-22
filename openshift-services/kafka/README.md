# Kafka

1. Run `deploy.sh` to deploy Red Hat's AMQ streams operator based on [Strimzi](https://github.com/strimzi/strimzi-kafka-operator).
1. After the operator is deployed, a Kafka cluster will be deployed in the `kafka` namespace.

## Verify

Use [kcat](https://github.com/edenhill/kcat) as follows to verify functionality.

```bash
## run kcat in container
kubectl run kcat -n kafka -it --rm --image=docker.io/edenhill/kcat:1.7.1 --command -- sh

## get metadata on topic
kcat -L -b cluster1-kafka-bootstrap -t topic1

## produce messages
echo "message1" | kcat -P -b cluster1-kafka-bootstrap -t topic1 -T
echo "message2" | kcat -P -b cluster1-kafka-bootstrap -t topic1 -T

## consume messages
kcat -C -b cluster1-kafka-bootstrap -t topic1 -o beginning -e 
```
