---
apiVersion: v1
kind: ConfigMap
metadata:
  name: rest-villains-config
data:
  quarkus.hibernate-orm.database.generation: validate
  quarkus.hibernate-orm.sql-load-script: no-file
  quarkus.opentelemetry.tracer.exporter.otlp.endpoint: ${opentelemetry_collector_endpoint} 
  # TODO: automate integration of OpenTelemetry wrapper JDBC driver
  # quarkus.datasource.jdbc.driver: io.opentelemetry.instrumentation.jdbc.OpenTelemetryDriver
  # quarkus.datasource.jdbc.url: jdbc:otel:postgresql://villains-db-primary:5432/villains-db
  # quarkus.datasource.jdbc.driver: org.postgresql.Driver
  # quarkus.datasource.jdbc.url: jdbc:postgresql://villains-db-primary:5432/villains-db