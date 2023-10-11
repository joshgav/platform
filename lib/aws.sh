function hosted_zone_id () {
    local hosted_zone_name=${1}

    # append '.' to zone name if needed
    regex='\.$'
    if [[ ! ${hosted_zone_name} =~ ${regex} ]]; then
        hosted_zone_name="${hosted_zone_name}."
    fi

    aws route53 list-hosted-zones --output json | \
        jq -r ".HostedZones[] | select (.Name == \"${hosted_zone_name}\") | .Id" | \
            sed 's`/hostedzone/``'
}

function vpc_id () {
    local vpc_name=${1}

    aws ec2 describe-vpcs --filter "Name=tag:Name,Values=${vpc_name}" --output json | \
        jq -r '.Vpcs[0].VpcId'
}

# usage:
#   Gather all subnets in a VPC as an array:
#
#   subnets=($(subnets_in_vpc ${cluster_name}-vpc))
#   echo "${subnets[0]}"
#   echo "${subnets[@]}"
function subnets_in_vpc () {
    local vpc_name=${1}

    vpc_id=$(vpc_id ${vpc_name})

    # invoke jq twice to output a stream of strings
    aws ec2 describe-subnets --filter "Name=vpc-id,Values=${vpc_id}" --output json | \
        jq '.Subnets[]' | jq -r '.SubnetId'
}

function subnet_id () {
    local subnet_name=${1}

    aws ec2 describe-subnets --filter "Name=tag:Name,Values=${subnet_name}" --output json | \
        jq -r '.Subnets[0].SubnetId'
}

function default_vpc_exists () {
    local region=${1}

    exists=$(false)

    vpc_id=$(aws ec2 describe-vpcs --region ${region} --output json | jq -r '.Vpcs[] | select(.IsDefault == true) | .VpcId')
    if [[ -n "${vpc_id}" ]]; then exists=$(true); fi

    return ${exists}
}