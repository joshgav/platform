#! /usr/bin/env bash

this_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
root_dir=$(cd ${this_dir}/../../../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi

cluster_name=${CLUSTER_NAME}
vpc_cidr='10.0.0.0/16'
subnet1_cidr='10.0.1.0/24'
subnet2_cidr='10.0.0.0/24'
aws_region=us-west-2
aws_az=us-west-2a

# # check instance types
# rosa list instances-types
#
# aws ec2 describe-instance-type-offerings --location-type availability-zone \
#     --filters "Name=location,Values=${aws_az}" --region ${aws_region} --output text

## 
vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=${cluster_name}" --query "Vpcs[0].VpcId" --output text)
if [[ "${vpc_id}" == "None" ]]; then
    echo "INFO: creating VPC"
    vpc_id=$(aws ec2 create-vpc --cidr-block "${vpc_cidr}" --query Vpc.VpcId --output text)
    aws ec2 create-tags --resources ${vpc_id} --tags "Key=Name,Value=${cluster_name}"
    aws ec2 modify-vpc-attribute --vpc-id ${vpc_id} --enable-dns-hostnames
    echo "INFO: created VPC ID ${vpc_id}"
fi
echo "INFO: using VPC ID ${vpc_id}"

subnet1_id=$(aws ec2 describe-subnets --filters "Name=cidr-block,Values=${subnet1_cidr}" --query "Subnets[0].SubnetId" --output text)
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

subnet2_id=$(aws ec2 describe-subnets --filters "Name=cidr-block,Values=${subnet2_cidr}" --query "Subnets[0].SubnetId" --output text)
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
echo "INFO: using routetable1 ID ${routetable1_id}"

natgw_id=$(aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=${cluster_name}" --query NatGateways[0].NatGatewayId --output text)
if [[ "${natgw_id}" == "None" ]]; then
    echo "INFO: create NAT Gateway"
    ipaddr_id=$(aws ec2 allocate-address --domain vpc --query AllocationId --output text)
    natgw_id=$(aws ec2 create-nat-gateway --subnet-id ${subnet1_id} --allocation-id ${ipaddr_id}  --query NatGateway.NatGatewayId --output text)
    aws ec2 create-tags --resources ${ipaddr_id}  --resources ${natgw_id} --tags "Key=Name,Value=${cluster_name}"
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
echo "INFO: using routetable2 ID ${routetable2_id}"
