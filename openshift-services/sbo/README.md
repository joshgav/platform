# Service Binding Operator

To enable the operator's service account to get and update knative services:

```bash
kubectl create clusterrolebinding service-binding-operator-knative-view \
    --clusterrole=knative-serving-namespaced-view \
    --serviceaccount='openshift-operators:service-binding-operator'

kubectl create clusterrolebinding service-binding-operator-knative-edit \
    --clusterrole=knative-serving-namespaced-edit \
    --serviceaccount='openshift-operators:service-binding-operator'
```
