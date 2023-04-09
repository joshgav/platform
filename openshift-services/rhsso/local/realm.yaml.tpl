apiVersion: keycloak.org/v1alpha1
kind: KeycloakRealm
metadata:
  name: main
  labels:
    keycloak: main
    realm: main
spec:
  instanceSelector:
    matchLabels:
      keycloak: main
  realm:
    realm: main
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