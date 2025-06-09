## AWS EFS CSI Driver

Based on <https://docs.redhat.com/en/documentation/red_hat_openshift_service_on_aws/4/html/storage/using-container-storage-interface-csi#persistent-storage-csi-aws-efs>


### ARNs

```bash
## examples
export cluster_name=rosa03
export account_id=942806864923
export oidc_issuer_id=oidc.op1.openshiftapps.com/2d24jfr0o6eu90nset5svce0sm5uru3i
```

- Role ARN: `arn:aws:iam::${aws_account_id}:role/${cluster_name}-aws-efs-csi-operator`
- Policy ARN: `arn:aws:iam::${aws_account_id}:policy/${cluster_name}-aws-efs-csi`

### Walkthrough

1. Follow steps below to create role for operator
1. Install the operator via the web console (instructions in docs)
    - Specify the ARN of the role created in the previous step
    - Via CLI, modify `operator/subscription.yaml` and add the AWS account ID for the Role ARN
1. Create a CSIDriver as specced in `operand/csidriver.yaml`
1. Create an EFS filesystem and note its ID (instructions in docs)
1. Create a StorageClass as specced in `operand/sc.yaml`
    - use the EFS FS ID from the previous step
1. Allow traffic for NFS into the Security Group associated with the EFS FS (instructions in docs)
1. Create a test PVC along the lines of `operand/test-pvc.yaml`

```bash
export cluster_name=${cluster_name}
export aws_account_id=${aws_account_id}

## retrieve aws_account_id
aws sts get-caller-identity --query Account --output text

## use oidc_issuer_id in policies/trust.json
oidc_issuer_id=$(rosa describe cluster -c ${cluster_name} -oyaml | \
  awk '/oidc_endpoint_url/ {print $2}' | cut -d '/' -f 3,4)
export oidc_issuer_id

## todo: envsubst for policies/trust.json
## edit policies/trust.json manually; specify oidc_issuer_id and aws_account_id
ROLE_ARN=$(aws iam create-role \
  --role-name "${cluster_name}-aws-efs-csi-operator" \
  --assume-role-policy-document file://policies/trust.json \
  --query "Role.Arn" --output text); echo $ROLE_ARN

POLICY_ARN=$(aws iam create-policy \
  --policy-name "${cluster_name}-aws-efs-csi" \
  --policy-document file://policies/policy.json \
  --query 'Policy.Arn' --output text); echo $POLICY_ARN

aws iam attach-role-policy \
  --role-name "${cluster_name}-aws-efs-csi-operator" \
  --policy-arn $POLICY_ARN
```
