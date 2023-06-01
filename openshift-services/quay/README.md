# Quay

Install QuayRegistry operator and custom resource type, then deploy a registry.

Requires ObjectBucketClaim resource type in cluster (via [Noobaa](../noobaa/)).

## Notes

- Use the special "config editor" route to update Quay config in a web form.
- For "super user" access in the web portal, create a new account via the main Quay route/site and add that account as a "super user" in Quay config.
- TODO: automate creating a user account and adding it as a super user.

## Resources

- https://github.com/quay/quay-operator
