apiVersion: keycloak.org/v1alpha1
kind: KeycloakRealm
metadata:
  name: app
  labels:
    keycloak: app
    realm: app
spec:
  instanceSelector:
    matchLabels:
      keycloak: app
  realm:
    realm: app
    enabled: true
    rememberMe: true
    users:
    - username: joshgav
      firstName: Josh
      lastName: Gavant
      email: joshgavant@gmail.com
      enabled: true
      realmRoles:
      - default-roles-main
      clientRoles:
        account:
        - manage-account
        - manage-consent
        - view-applications
        - view-consent
        - view-profile
        - delete-account
      credentials:
      - type: password
        value: ${KEYCLOAK_USER_SECRET}
        temporary: true