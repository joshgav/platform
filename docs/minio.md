# Minio TLS Certificates

Minio uses its own TLS certificates and CA by default. Some capabilities must
explicitly specify that CA.

## Logging with Loki stack

- Patch the `ClusterLogging` resource:

```yaml
spec:
  storage:
    tls:
      caName: tenant0-tls
```
- Copy minio's CA cert to the openshift-logging namespace

```bash
temp_file=$(mktemp)
oc get secret -n minio-tenant tenant0-tls -oyaml | \
    jq -r '.data."public.crt" | @base64d' > ${temp_file}
oc create configmap tenant0-tls -n openshift-logging --from-file "service-ca.crt=${temp_file}"
```

- Add minio's TLS CA to local trusted roots:

```bash
sudo cp ${temp_file} /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust extract
```
