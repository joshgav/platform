# Quay

Installs QuayRegistry operator and custom resource type, then deploys a registry.

Requires ObjectBucketClaim resource type in cluster (via [Noobaa](../noobaa/)).

This directory deploys object storage manually; i.e., `managed: false` is set on
the `objectstorage` component. It uses Noobaa alone rather than OCS/ODF. The
main difference is that the `storageClassName` in the ObjectBucketClaim is
`noobaa.noobaa.io` rather than `openshift-storage.noobaa.io`. Because object
storage is configured manually the config must also be set manually to include
bucket metadata and secrets.

## Notes

- To configure short names: https://docs.openshift.com/container-platform/4.10/openshift_images/image-configuration.html#images-configuration-shortname_image-configuration
- To update the global pull secret: https://docs.openshift.com/container-platform/4.10/openshift_images/managing_images/using-image-pull-secrets.html#images-update-global-pull-secret_using-image-pull-secrets
- Use the special "config editor" route to update Quay config in a web form.
- For "super user" access in the web portal, create a new account via the main Quay route/site and add that account as a "super user" in Quay config.
- TODO: automate creating a user account and adding it as a super user.

## Resources

- https://github.com/quay/quay-operator
- Quay configuration: <https://docs.projectquay.io/deploy_quay_on_openshift_op_tng.html>