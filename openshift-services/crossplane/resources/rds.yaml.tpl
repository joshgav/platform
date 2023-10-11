apiVersion: rds.aws.crossplane.io/v1alpha1
kind: DBInstance
metadata:
  name: example-dbinstance
  namespace: ${target_namespace}
spec:
  providerConfigRef:
    name: default
  forProvider:
    region: us-west-2
    allocatedStorage: 20
    autoMinorVersionUpgrade: true
    autogeneratePassword: true
    backupRetentionPeriod: 14
    dbInstanceClass: db.t3.micro # needs to support engine and -version (see AWS Docs: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.Support)
    dbName: apiserver
    engine: postgres
    engineVersion: "15.2"
    allowMajorVersionUpgrade: true # unset per default (Note: supported dbInstanceClass and dbParameterGroup with correct dbParameterGroupFamily needed, before majorVersion upgrade possible; applyImmediately matters)
    masterUsername: adminuser
    masterUserPasswordSecretRef:
      key: password
      name: example-dbinstance
      namespace: ${target_namespace}
    preferredBackupWindow: "7:00-8:00"
    preferredMaintenanceWindow: "Sat:8:00-Sat:11:00"
    publiclyAccessible: false
    skipFinalSnapshot: true
    storageEncrypted: false
    storageType: gp2
    dbParameterGroupName: example-dbparametergroup
    applyImmediately: true
    deleteAutomatedBackups: false # default is true
  writeConnectionSecretToRef:
    name: example-dbinstance-out
    namespace: ${target_namespace}
---
apiVersion: rds.aws.crossplane.io/v1alpha1
kind: DBParameterGroup
metadata:
  name: example-dbparametergroup
  namespace: ${target_namespace}
spec:
  providerConfigRef:
    name: default
  forProvider:
    region: us-west-2
    dbParameterGroupFamilySelector:
      engine: postgres
    description: example
    parameters:
      - parameterName: application_name
        parameterValue: "example"
        applyMethod: immediate
---
apiVersion: v1
kind: Secret
metadata:
  name: example-dbinstance
  namespace: ${target_namespace}
type: Opaque
stringData:
  password: testPassword!123