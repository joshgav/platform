---
apiVersion: v1
kind: ConfigMap
metadata:
  name: rest-heroes-config
data:
  quarkus.hibernate-orm.database.generation: validate
  quarkus.hibernate-orm.sql-load-script: no-file
  quarkus.opentelemetry.tracer.exporter.otlp.endpoint: ${opentelemetry_collector_endpoint}