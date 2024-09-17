kind: Secret
apiVersion: v1
metadata:
  name: init-config-bundle
  namespace: quay
type: Opaque
stringData:
  # see https://docs.projectquay.io/config_quay.html
  config.yaml: |
    SETUP_COMPLETE: true
    FEATURE_BUILD_SUPPORT: false
    FEATURE_DIRECT_LOGIN: true
    FEATURE_MAILING: false
    FEATURE_UI_V2: true
    REGISTRY_TITLE: Red Hat Quay
    REGISTRY_TITLE_SHORT: Red Hat Quay
    ENTERPRISE_LOGO_URL: /static/img/RH_Logo_Quay_Black_UX-horizontal.svg
    AUTHENTICATION_TYPE: Database
    ALLOW_PULLS_WITHOUT_STRICT_LOGGING: false
    DEFAULT_TAG_EXPIRATION: 2w
    TAG_EXPIRATION_OPTIONS:
    - 2w
    TEAM_RESYNC_STALE_TIME: 60m
    TESTING: false
    SUPER_USERS:
    - joshgav
    - quayadmin