apiVersion: config.openshift.io/v1
kind: APIServer
metadata:
  name: cluster
spec:
  servingCerts:
    namedCertificates:
      - names:
        - 'api.${OPENSHIFT_CLUSTER_NAME}.${OPENSHIFT_BASE_DOMAIN}'
        servingCertificate:
          name: openshift-apiserver-keypair