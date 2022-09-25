---
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: event-statistics
    application: event-stats
    system: quarkus-super-heroes
  name: event-statistics-config
data:
  mp.messaging.connector.smallrye-kafka.apicurio.registry.url: ${apicurio_base_url}/apis/registry/v2
  kafka.bootstrap.servers: ${kafka_bootstrap_servers}
  quarkus.opentelemetry.tracer.exporter.otlp.endpoint: ${opentelemetry_collector_endpoint}
  quarkus.liquibase-mongodb.migrate-at-start: 'false'