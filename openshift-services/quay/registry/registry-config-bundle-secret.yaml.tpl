kind: Secret
apiVersion: v1
metadata:
  name: init-config-bundle
  namespace: quay
type: Opaque
stringData:
  # see https://docs.projectquay.io/config_quay.html
  config.yaml: |
    ALLOW_PULLS_WITHOUT_STRICT_LOGGING: false
    AUTHENTICATION_TYPE: Database
    DEFAULT_TAG_EXPIRATION: 2w
    ENTERPRISE_LOGO_URL: /static/img/RH_Logo_Quay_Black_UX-horizontal.svg
    FEATURE_BUILD_SUPPORT: false
    FEATURE_DIRECT_LOGIN: true
    FEATURE_MAILING: false
    FEATURE_UI_V2: true
    FEATURE_UI_V2_REPO_SETTINGS: true
    FEATURE_AUTO_PRUNE: true
    REGISTRY_TITLE: Red Hat Quay
    REGISTRY_TITLE_SHORT: Red Hat Quay
    SETUP_COMPLETE: true
    TAG_EXPIRATION_OPTIONS:
    - 2w
    TEAM_RESYNC_STALE_TIME: 60m
    TESTING: false
    SUPER_USERS:
    - joshgav
    - quayadmin
    SERVER_HOSTNAME: ${quay_server_name}
data:
  ssl.cert: ${quay_tls_crt_b64}
  ssl.key: ${quay_tls_key_b64}
