# OpenShift Service Mesh with Observability

## Setup

1. Install ODF with Multicloud Gateway in standalone mode (or full mode).
1. Run `./deploy-tempo.sh` to deploy a TempoStack and COO UIPlugin
1. Run `./deploy.istio.sh` to deploy Istio and Kiali
1. Run `./deploy-bookinfo.sh` to deploy bookinfo and its podmonitors for Kiali

All scripts are idempotent - that is, they can be run over and over again to apply changes.

## Access

- Kiali: <https://kiali-istio-system.apps.${CLUSTER_DOMAIN}/>
- Jaeger: <https://tempo-default-gateway-tempo-observability.apps.${CLUSTER_DOMAIN}/api/traces/v1/dev/search>
- bookinfo: <http://istio-ingressgateway-bookinfo.apps.${CLUSTER_DOMAIN}/productpage>

## Resources

### Tempo
- Deploy Tempo operator and TempoStack instance. Enable receiving traces from OpenTelemetry collector.
    - Link: <https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/distributed_tracing/distributed-tracing-platform-tempo>
- To view traces in Tempo, go to `https://<gateway_route>/api/traces/v1/<tenant_name>/search`, e.g., <https://tempo-tempostack-gateway-telemetry.apps.cluster-t9626.t9626.sandbox2506.opentlc.com/api/traces/v1/dev/search>

### Istio/Service Mesh
- Docs: https://docs.redhat.com/en/documentation/red_hat_openshift_service_mesh/3.0
- Enable tracing in Istio (service mesh) and send traces to an OpenTelemetry collector
    - https://docs.redhat.com/en/documentation/red_hat_openshift_service_mesh/3.0/html/observability/distributed-tracing-and-service-mesh
- Deploy an Istio ingress gateway using `Deployment` and `Service`: `kubectl apply -f https://github.com/istio-ecosystem/sail-operator/blob/main/chart/samples/ingress-gateway.yaml`
- Set up bookinfo in OpenShift: https://docs.redhat.com/en/documentation/red_hat_openshift_service_mesh/3.0/html/installing/ossm-installing-service-mesh#ossm-about-bookinfo-application_ossm-discoveryselectors-scope-service-mesh

### Kiali
- Kiali CR parameters: https://github.com/kiali/kiali-operator/blob/master/roles/default/kiali-deploy/defaults/main.yml
- Tempo with Kiali: https://kiali.io/docs/configuration/p8s-jaeger-grafana/tracing/tempo/#

### Example Istio+Otel+Tempo
- https://github.com/pavolloffay/migrate-from-jaeger-to-tempo
- https://github.com/pavolloffay/openshift-observability-manifests

### TODO: Connectivity Link (Kuadrant)
- https://developers.redhat.com/products/red-hat-connectivity-link/overview
- https://kuadrant.io/
- https://www.solutionpatterns.io/soln-pattern-connectivity-link/solution-pattern/index.html


- For Istio in ROSA: <https://access.redhat.com/solutions/6529231>