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