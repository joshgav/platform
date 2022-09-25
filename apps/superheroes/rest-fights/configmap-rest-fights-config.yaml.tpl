apiVersion: v1
kind: ConfigMap
metadata:
  name: rest-fights-config
data:
  quarkus.liquibase-mongodb.migrate-at-start: "false"
  quarkus.mongodb.hosts: fights-db:27017
  quarkus.stork.hero-service.service-discovery.type: kubernetes
  quarkus.stork.hero-service.service-discovery.application: rest-heroes
  quarkus.stork.hero-service.service-discovery.refresh-period: 1M
  quarkus.stork.villain-service.service-discovery.type: kubernetes
  quarkus.stork.villain-service.service-discovery.application: rest-villains
  quarkus.stork.villain-service.service-discovery.refresh-period: 1M
  quarkus.rest-client.hero-client.url: stork://hero-service/
  fight.villain.client-base-url: stork://villain-service/
  mp.messaging.connector.smallrye-kafka.apicurio.registry.url: ${apicurio_base_url}/apis/registry/v2
  kafka.bootstrap.servers: ${kafka_bootstrap_servers}
  quarkus.opentelemetry.tracer.exporter.otlp.endpoint: ${opentelemetry_collector_endpoint}