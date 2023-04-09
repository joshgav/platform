# Resource Operator

## Reconcile code

Add to api/v1alpha1/exampleresource_types.go:33

```go
ExampleAttribute string `json:"exampleAttribute,omitempty"`
```

Add to controllers/exampleresource_controller.go:52

```go
log := log.FromContext(ctx, "namespace", req.Namespace, "name", req.Name)
log.Info("Reconciling ExampleResource")

resource := &resourcesv1alpha1.ExampleResource{}
err := r.Client.Get(ctx, req.NamespacedName, resource)
if err != nil {
	if errors.IsNotFound(err) {
		// Request object not found, could have been deleted after reconcile request.
		// Owned objects are automatically garbage collected. For additional cleanup logic use finalizers.
		// Return and don't requeue
		return reconcile.Result{}, nil
	}
	// Error reading the object - requeue the request.
	return reconcile.Result{}, err
}

log.Info("Found ExampleResource", "ExampleAttribute", resource.Spec.ExampleAttribute)
```