# Quay

Installs QuayRegistry operator then deploys a registry.

## Notes

### Alternate Hostname with TLS

- Docs:
    - <https://docs.redhat.com/en/documentation/red_hat_quay/3.13/html/deploying_the_red_hat_quay_operator_on_openshift_container_platform/configuring-traffic-ingress>
    - <https://docs.redhat.com/en/documentation/red_hat_quay/3.13/html/deploying_the_red_hat_quay_operator_on_openshift_container_platform/operator-custom-ssl-certs-config-bundle>
- Generate a certificate with "SAN: quay.aws.joshgav.com" and add it to the config bundle. See registry/certificate.yaml.tpl for an example certificate request.
- After the certificate is ready grab the cert and key from the secret and put them with the config bundle.
- Add `SERVER_HOSTNAME: quay.aws.joshgav.com` to config-bundle to change the advertised name in the Web UI
    - This also changes the host name in the route!

### Config

- To find the current secret with custom config: `oc get quayregistries registry -ojson | jq '.spec.configBundleSecret'`
- To configure short names: https://docs.openshift.com/container-platform/4.10/openshift_images/image-configuration.html#images-configuration-shortname_image-configuration
- To update the global pull secret: https://docs.openshift.com/container-platform/4.10/openshift_images/managing_images/using-image-pull-secrets.html#images-update-global-pull-secret_using-image-pull-secrets
- Use the special "config editor" route to update Quay config in a web form.
- For "super user" access in the web portal, create a new account via the main Quay route/site and add that account as a "super user" in Quay config.
- TODO: automate creating a user account and adding it as a super user.

## Resources

- Quay configuration: <https://docs.projectquay.io/config_quay.html>
- https://docs.redhat.com/en/documentation/red_hat_quay
- https://github.com/quay/quay-operator
