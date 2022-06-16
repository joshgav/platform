# Emissary ingress controller

To verify/debug emissary ingress controller, access port of
`emissary-ingress-admin` service via HTTP with path `ambassador/v0/diag/`.

`Listener`s for HTTP and HTTPS are created here. `Host`s should be created along
with `Ingress`es in app-specific configs.