# MongoDB

Based on <https://github.com/mongodb/mongodb-kubernetes-operator>.

The `deploy-operator.sh` script deploys the MongoDB operator and installs the `MongoDBCommunity` CRD.

For an example of how to create a DB cluster after the operator is deployed see
the [Superheroes app](./../../apps/superheroes/rest-fights).

## Notes

It will be necessary to grant SBO rights to view and edit resources.

```bash
sa='openshift-operators:service-binding-operator'
oc create clusterrolebinding sbo-knative \
    --clusterrole=knative-serving-admin \
    --serviceaccount "${sa}"
oc create clusterrolebinding sbo-mongodb \
    --clusterrole=mongodbcommunity-view \
    --serviceaccount "${sa}"
```