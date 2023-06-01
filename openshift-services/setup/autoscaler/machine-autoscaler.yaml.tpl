apiVersion: autoscaling.openshift.io/v1beta1
kind: MachineAutoscaler
metadata:
  name: ${MACHINESET_NAME}
  namespace: openshift-machine-api
spec:
  minReplicas: 1 
  maxReplicas: 12 
  scaleTargetRef: 
    apiVersion: machine.openshift.io/v1beta1
    kind: MachineSet 
    name: ${MACHINESET_NAME}