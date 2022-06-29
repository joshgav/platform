## Eventing

- https://knative.dev/docs/install/yaml-install/eventing/install-eventing-with-yaml/
- https://knative.dev/docs/install/operator/configuring-eventing-cr/

## Serving

- https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/
- https://knative.dev/docs/install/operator/configuring-serving-cr/

## Brokers and Channels

Channels are for point-to-point communications and are part of the `messaging.knative.dev` group.

Brokers are for routed, stored and forwarded communications and are part of the
`eventing.knative.dev` group.

Brokers are layered over Channels. The multi-tenant (MT) channel-based broker
requires an existing Channel implementation. By default it uses the
InMemoryChannel.

The Kafka broker depends on an existing Kafka cluster.

- https://knative.dev/docs/eventing/broker/kafka-broker/
- https://docs.openshift.com/container-platform/4.6/serverless/admin_guide/serverless-kafka-admin.html
- https://docs.openshift.com/container-platform/4.10/serverless/develop/serverless-kafka-developer.html
