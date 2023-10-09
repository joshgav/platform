#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

function reconcile_vpc {
    local vpc_cidr=${1:-'10.0.0.0/16'}
    local cluster_name=${2:-${cluster_name}}

    vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=${cluster_name}" --query "Vpcs[0].VpcId" --output text)
    if [[ "${vpc_id}" == "None" ]]; then
        echo "INFO: creating VPC"
        vpc_id=$(aws ec2 create-vpc --cidr-block "${vpc_cidr}" --query Vpc.VpcId --output text)
        aws ec2 create-tags --resources ${vpc_id} --tags "Key=Name,Value=${cluster_name}"
        aws ec2 modify-vpc-attribute --vpc-id ${vpc_id} --enable-dns-hostnames
        echo "INFO: created VPC ID ${vpc_id}"
    fi
    echo "INFO: using VPC ID ${vpc_id}"
}

function reconcile_az {
    local subnet1_cidr=${1:-'10.0.0.0/24'}
    local subnet2_cidr=${2:-'10.0.1.0/24'}
    local aws_region=${3:-'us-west-2'}
    local aws_az=${4:-'us-west-2a'}
    local cluster_name=${5:-${cluster_name}}

    subnet1_id=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${cluster_name}-public" "Name=availability-zone,Values=${aws_az}" --query "Subnets[0].SubnetId" --output text)
    if [[ "${subnet1_id}" == "None" ]]; then
        echo "INFO: create subnet 1"
        subnet1_id=$(aws ec2 create-subnet --vpc-id ${vpc_id} \
            --cidr-block "${subnet1_cidr}" \
            --availability-zone ${aws_az} \
            --query Subnet.SubnetId \
            --output text)
        aws ec2 create-tags --resources ${subnet1_id} \
            --tags "Key=Name,Value=${cluster_name}-public"
        echo "INFO: created subnet1 ID ${subnet1_id}"
    fi
    echo "INFO: using subnet1 ID ${subnet1_id}"

    subnet2_id=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=${cluster_name}-private" "Name=availability-zone,Values=${aws_az}" --query "Subnets[0].SubnetId" --output text)
    if [[ "${subnet2_id}" == "None" ]]; then
        echo "INFO: create subnet 2"
        subnet2_id=$(aws ec2 create-subnet --vpc-id ${vpc_id} \
            --cidr-block "${subnet2_cidr}" \
            --availability-zone ${aws_az} \
            --query Subnet.SubnetId \
            --output text)
        aws ec2 create-tags --resources ${subnet2_id} \
            --tags "Key=Name,Value=${cluster_name}-private"
        echo "INFO: created subnet2 ID ${subnet2_id}"
    fi
    echo "INFO: using subnet2 ID ${subnet2_id}"

    inetgw_id=$(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=${cluster_name}" --query "InternetGateways[0].InternetGatewayId" --output text)
    if [[ "${inetgw_id}" == "None" ]]; then
        echo "INFO: creating Internet Gateway"
        inetgw_id=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
        aws ec2 attach-internet-gateway --vpc-id ${vpc_id} --internet-gateway-id ${inetgw_id}
        aws ec2 create-tags --resources ${inetgw_id} --tags "Key=Name,Value=${cluster_name}"
        echo "INFO: created Internet Gateway ID ${inetgw_id}"
    fi
    echo "INFO: using Internet Gateway ID ${inetgw_id}"

    routetable1_id=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=${cluster_name}" --query "RouteTables[0].RouteTableId" --output text)
    if [[ "${routetable1_id}" == "None" ]]; then
        echo "INFO: creating routetable1"
        routetable1_id=$(aws ec2 create-route-table --vpc-id ${vpc_id} --query RouteTable.RouteTableId --output text)
        aws ec2 associate-route-table --subnet-id ${subnet1_id} --route-table-id ${routetable1_id}
        aws ec2 create-route --route-table-id ${routetable1_id} --destination-cidr-block "0.0.0.0/0" --gateway-id ${inetgw_id}
        aws ec2 create-tags --resources ${routetable1_id} --tags "Key=Name,Value=${cluster_name}"
        echo "INFO: created routetable1 ID ${routetable1_id}"
    fi
    aws ec2 associate-route-table --subnet-id ${subnet1_id} --route-table-id ${routetable1_id}
    echo "INFO: using routetable1 ID ${routetable1_id}"

    natgw_id=$(aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=${cluster_name}" --query NatGateways[0].NatGatewayId --output text)
    if [[ "${natgw_id}" == "None" ]]; then
        echo "INFO: create NAT Gateway"
        ipaddr_id=$(aws ec2 allocate-address --domain vpc --query AllocationId --output text)
        natgw_id=$(aws ec2 create-nat-gateway --subnet-id ${subnet1_id} --allocation-id ${ipaddr_id}  --query NatGateway.NatGatewayId --output text)
        aws ec2 create-tags --resources ${ipaddr_id}  --resources ${natgw_id} --tags "Key=Name,Value=${cluster_name}"
        sleep 5
        echo "INFO: created NAT Gateway ID ${natgw_id}"
    fi
    echo "INFO: using NAT Gateway ID ${natgw_id}"

    routetable2_id=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=${cluster_name}-private" --query "RouteTables[0].RouteTableId" --output text)
    if [[ "${routetable2_id}" == "None" ]]; then
        echo "INFO: creating routetable2"
        routetable2_id=$(aws ec2 create-route-table --vpc-id ${vpc_id} --query RouteTable.RouteTableId --output text)
        aws ec2 associate-route-table --subnet-id ${subnet2_id} --route-table-id ${routetable2_id}
        aws ec2 create-route --route-table-id ${routetable2_id} --destination-cidr-block 0.0.0.0/0 --gateway-id ${natgw_id}
        aws ec2 create-tags --resources ${routetable2_id} ${ipaddr_id} --tags "Key=Name,Value=${cluster_name}-private"
        echo "INFO: created routetable2 ID ${routetable2_id}"
    fi
    aws ec2 associate-route-table --subnet-id ${subnet2_id} --route-table-id ${routetable2_id}
    echo "INFO: using routetable2 ID ${routetable2_id}"
}

cluster_name=${CLUSTER_NAME}
vpc_cidr='10.0.0.0/16'

declare -A azs_map
aws_region=${AWS_REGION:-us-west-2}
az1=${aws_region}a
az2=${aws_region}b
az3=${aws_region}c
azs_map=(
    ["${az1}"]='10.0.0.0/24 10.0.1.0/24'
    ["${az2}"]='10.0.2.0/24 10.0.3.0/24'
    ["${az3}"]='10.0.4.0/24 10.0.5.0/24'
)

reconcile_vpc ${vpc_cidr} ${cluster_name}

for aws_az in ${az1} ${az2} ${az3}; do
    for subnet in "${azs_map[${aws_az}]}"; do
        subnet1_cidr=$(echo ${subnet} | awk '{print $1}')
        subnet2_cidr=$(echo ${subnet} | awk '{print $2}')
    done
    echo "INFO: reconcile_az ${subnet1_cidr} ${subnet2_cidr} ${aws_region} ${aws_az} ${cluster_name}"
    reconcile_az ${subnet1_cidr} ${subnet2_cidr} ${aws_region} ${aws_az} ${cluster_name}
done