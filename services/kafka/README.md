# Kafka

## Helpers

Use [kcat](https://github.com/edenhill/kcat) to verify functionality.

**Run kcat pod**

```bash
kubectl run kcat -n kafka -it --rm --image=docker.io/edenhill/kcat:1.7.1 --command -- sh
```

**Use kcat**

```bash
## metadata
kcat -L -b cluster1-kafka-bootstrap -t topic1

## produce
echo "message1" | kcat -P -b cluster1-kafka-bootstrap -t topic1 -T
echo "message2" | kcat -P -b cluster1-kafka-bootstrap -t topic1 -T

## consume
kcat -C -b cluster1-kafka-bootstrap -t topic1 -o beginning -e 
```
