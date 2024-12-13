# Quay

## Resources

- https://docs.redhat.com/en/documentation/red_hat_quay
- https://github.com/quay/quay-operator

## Notes

Installs QuayRegistry operator and custom resource type, then deploys a registry.

Requires ObjectBucketClaim resource type in cluster (via [Noobaa](../noobaa/)).

This directory deploys object storage manually; i.e., `managed: false` is set on
the `objectstorage` component. It uses Noobaa alone rather than OCS/ODF. The
main difference is that the `storageClassName` in the ObjectBucketClaim is
`noobaa.noobaa.io` rather than `openshift-storage.noobaa.io`. Because object
storage is configured manually the config must also be set manually to include
bucket metadata and secrets.

## Notes

### Alternate Hostname

- Docs: <https://docs.redhat.com/en/documentation/red_hat_quay/3.13/html/deploying_the_red_hat_quay_operator_on_openshift_container_platform/configuring-traffic-ingress>
- Generate a certificate with "SAN: quay.aws.joshgav.com" and add it to the config bundle
    - See registry/certificate.yaml for an example certificate request
    - After the certificate is set from Let's Encrypt, grab the cert and key from the secret and put them with the config bundle as described here: https://docs.redhat.com/en/documentation/red_hat_quay/3.12/html/deploying_the_red_hat_quay_operator_on_openshift_container_platform/configuring-traffic-ingress#creating-config-bundle-secret-tls-cert-key-pair
- Add `SERVER_NAME: quay.aws.joshgav.com` to config-bundle to change the advertised name in the Web UI
    - This also changes the host name in the route!

### Config

- To find the current secret with custom config: `oc get quayregistries registry -ojson | jq '.spec.configBundleSecret'`
- To configure short names: https://docs.openshift.com/container-platform/4.10/openshift_images/image-configuration.html#images-configuration-shortname_image-configuration
- To update the global pull secret: https://docs.openshift.com/container-platform/4.10/openshift_images/managing_images/using-image-pull-secrets.html#images-update-global-pull-secret_using-image-pull-secrets
- Use the special "config editor" route to update Quay config in a web form.
- For "super user" access in the web portal, create a new account via the main Quay route/site and add that account as a "super user" in Quay config.
- TODO: automate creating a user account and adding it as a super user.

## Resources

- Quay configuration: <https://docs.projectquay.io/deploy_quay_on_openshift_op_tng.html>