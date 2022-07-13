## helper functions for finding AWS resource IDs

function default_vpc_id {
    aws ec2 describe-vpcs --output json | jq -r '.Vpcs[] | select(.IsDefault == true) | .VpcId'
}

function subnet_id_by_name {
    subnet_name=${1}
    aws ec2 describe-subnets --output json | \
        jq -r ".Subnets[] | select(.Tags[] | select(.Key == \"Name\" and (.Value | match(\"${subnet_name}\")))) | .SubnetId"
}

function vpc_id_by_subnet_name {
    subnet_name=${1}
    aws ec2 describe-subnets --output json | \
        jq -r ".Subnets[] | select(.Tags[] | select(.Key == \"Name\" and (.Value | match(\"${subnet_name}\")))) | .VpcId"
}

function default_sg_id_for_vpc {
    vpc_id=${1}
    aws ec2 describe-security-groups --output json | \
        jq -r ".SecurityGroups[] | select((.GroupName == \"default\") and (.VpcId == \"${vpc_id}\")) | .GroupId"
}

function sg_id_by_name {
    sg_name=${1:-Base}
    aws ec2 describe-security-groups --filter "Name=group-name,Values=${sg_name}" --output json | jq -r '.SecurityGroups[].GroupId'
}