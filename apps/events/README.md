# Events App

A pair of functions/handlers that send and receive events via a Knative Eventing broker.

Requires knative eventing and serving; depends on namespace default broker.

Deploy with `deploy.sh`. Specify a registry if desired: `deploy.sh quay.io/joshgav`.

`kn func` requires an interactive sign in to a registry on first access at least.
