apiVersion: keycloak.org/v1alpha1
kind: KeycloakRealm
metadata:
  name: app-realm
  labels:
    app: keycloak
spec:
  instanceSelector:
    matchLabels:
      app: keycloak
  realm:
    id: app
    realm: app
    displayName: app
    enabled: true
    rememberMe: true
    userFederationProviders:
    - id: 6ee37cfc-9fcd-4815-9bc8-3d929023abf0
      displayName: msad
      providerName: ldap
      config:
        connectionUrl: ldap://msad.aws.joshgav.com:389/
        bindDn: "CN=keycloak,CN=Users,DC=aws,DC=joshgav,DC=com"
        bindCredential: "${LDAP_BIND_SECRET}"
        editMode: WRITABLE
        vendor: "ad"
        usersDn: "OU=Spring Test App,DC=aws,DC=joshgav,DC=com"
        searchScope: "2"
        userObjectClasses: "person, organizationalPerson, user"
        rdnLDAPAttribute: cn
        usernameLDAPAttribute: "sAMAccountName"
        uuidLDAPAttribute: "objectGUID"
    userFederationMappers:
    - id: a07f2780-cac7-4572-89c3-834c607ce1d9
      name: msad-group2role-mapper
      federationProviderDisplayName: msad
      federationMapperType: role-ldap-mapper
      config:
        "roles.dn": "OU=Groups,OU=Spring Test App,DC=aws,DC=joshgav,DC=com"
        mode: LDAP_ONLY
        "membership.attribute.type": "DN"
        "user.roles.retrieve.strategy": LOAD_ROLES_BY_MEMBER_ATTRIBUTE
        "membership.ldap.attribute": "member"
        "membership.user.ldap.attribute": "sAMAccountName"
        "role.name.ldap.attribute": "cn"
        "memberof.ldap.attribute": "memberOf"
        "use.realm.roles.mapping": "true"
        "role.object.classes": "group"
    - id: 4dfbd8fa-a8ca-4c3e-b7d6-f04b05302c35
      name: username
      federationProviderDisplayName: msad
      federationMapperType: user-attribute-ldap-mapper
      config:
        "ldap.attribute": sAMAccountName
        "user.model.attribute": "username"
        "is.mandatory.in.ldap": "true"
        "is.binary.attribute": "false"
        "read.only": "false"
        "always.read.value.from.ldap": "false"
    - id: d5e5eb08-b4fe-4563-aa8b-153f661586b5
      name: MSAD account controls
      federationMapperType: msad-user-account-control-mapper
      federationProviderDisplayName: msad
    - id: 4f53c4ac-27d1-4bbc-814d-34e4f3cf84c5
      name: modify date
      federationMapperType: user-attribute-ldap-mapper
      federationProviderDisplayName: msad
      config:
        "ldap.attribute": "whenChanged"
        "is.mandatory.in.ldap": "false"
        "read.only": "true"
        "always.read.value.from.ldap": "true"
        "user.model.attribute": "modifyTimestamp"
    - id: 82fc8107-696a-446c-bf91-12108e8b0693
      name: last name
      federationMapperType: user-attribute-ldap-mapper
      federationProviderDisplayName: msad
      config:
        "ldap.attribute": "sn"
        "is.mandatory.in.ldap": "true"
        "read.only": "true"
        "always.read.value.from.ldap": "true"
        "user.model.attribute": "lastName"
    - id: ac5999ab-0d66-4eaa-9272-a5aca891efa1
      name: "full name"
      federationMapperType: full-name-ldap-mapper
      federationProviderDisplayName: msad
      config:
        "read.only": "true"
        "write.only": "false"
        "ldap.full.name.attribute": "cn"
    - id: b7482fb0-30d2-415d-b10c-0182b6fba493
      name: email
      federationMapperType: user-attribute-ldap-mapper
      federationProviderDisplayName: msad
      config:
        "ldap.attribute": mail
        "is.mandatory.in.ldap": "false"
        "always.read.value.from.ldap": "false"
        "read.only": "true"
        "user.model.attribute": "email"
    - id: b0407433-8850-457b-a607-b9a3ed083c74
      name: creation date
      federationMapperType: user-attribute-ldap-mapper
      federationProviderDisplayName: msad
      config:
        "ldap.attribute": "whenCreated"
        "is.mandatory.in.ldap": "false"
        "read.only": "true"
        "always.read.value.from.ldap": "true"
        "user.model.attribute": "createTimestamp"