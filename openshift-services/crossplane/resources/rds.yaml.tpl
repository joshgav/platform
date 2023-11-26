apiVersion: rds.aws.upbound.io/v1beta1
kind: Instance
metadata:
  name: simple
  namespace: ${target_namespace}
spec:
  providerConfigRef:
    name: default
  writeConnectionSecretToRef:
    name: dbinstance-simple-connection
    namespace: ${target_namespace}
  forProvider:
    allocatedStorage: 20
    allowMajorVersionUpgrade: true
    autoMinorVersionUpgrade: true
    applyImmediately: true
    autoGeneratePassword: true
    backupRetentionPeriod: 14
    backupWindow: "7:00-8:00"
    dbName: apiserver
    deleteAutomatedBackups: false
    engine: postgres
    engineVersion: "15"
    instanceClass: db.t3.micro
    maintenanceWindow: "Sat:8:00-Sat:11:00"
    parameterGroupName: simple
    passwordSecretRef:
      name: rdsinstance-simple-master-password
      namespace: ${target_namespace}
      key: password
    publiclyAccessible: false
    region: ${AWS_REGION}
    skipFinalSnapshot: true
    storageEncrypted: false
    storageType: gp3
    username: adminuser
---
apiVersion: rds.aws.upbound.io/v1beta1
kind: ParameterGroup
metadata:
  name: simple
  namespace: ${target_namespace}
spec:
  providerConfigRef:
    name: default
  forProvider:
    description: simple
    region: ${AWS_REGION}
    family: postgres15
    parameter:
      - name: application_name
        value: "simple"
        applyMethod: immediate
---
apiVersion: v1
kind: Secret
metadata:
  name: rdsinstance-simple-master-password
  namespace: ${target_namespace}
type: Opaque
stringData:
  password: testPassword!123