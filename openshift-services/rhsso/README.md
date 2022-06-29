# Keycloak

To enable federation with Windows Active Directory via LDAP, set LDAP parameters
in `./msad/.env` prior to running `make openshift-sso-realm`.

If you don't need AD support you can disable that provider once Keycloak is
online.

Perhaps in the future we should separate the `app` realm config from
the `msad` federation provider.