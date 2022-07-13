#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

ami_cache_dir=${this_dir}/_ami_cache
mkdir -p "${ami_cache_dir}"

echo "INFO: getting and caching latest full AMIs list..."
# aws ec2 describe-images --output json > ${ami_cache_dir}/_ami_cache.json

function amis_for_regex {
    export ami_regex=${1:-'^RHEL'}
    export platform=${2:-'Red Hat Enterprise Linux'}

    query=$(echo '[ .Images[] |
        select(.Name? | type == "string") |
            select((.PlatformDetails? | match("${platform}"))
                and (.Architecture? | match("x86_64"))
                and (.Name | match("${ami_regex}"))) |
                    { "Name": .Name, "Description": .Description, "ImageId": .ImageId } ] |
                    sort_by(.Name)' | envsubst)

    # echo "DEBUG: query: ${query}"

    ami_regex_simplified=$(echo "${ami_regex}" | sed 's/\W//')
    cache_file=${ami_cache_dir}/_ami_cache_${ami_regex_simplified}.json

    echo "INFO: caching AMIs list for regex '${ami_regex}' to ${cache_file}"
    cat "${ami_cache_dir}/_ami_cache.json" | jq -r "${query}" > "${cache_file}"
}

amis_for_regex "^RHEL" "Red Hat Enterprise Linux"
amis_for_regex "^Windows_Server-2022-English-Full-ContainersLatest" Windows
amis_for_regex "fedora" "Linux/UNIX"
amis_for_regex "alma" "Linux/UNIX"

windows_latest_image_id=$(cat "${ami_cache_dir}/_ami_cache.json" | \
    jq -r '[ .Images[] | 
                select(.Name? | type == "string") |
                select((.PlatformDetails? | match("Windows")) 
                and (.Architecture? | match("x86_64")) 
                and (.Name | match("^Windows_Server-2022-English-Full-ContainersLatest"))) ] | 
                    max_by(.CreationDate) | 
                        .ImageId')
if [[ -n "${windows_latest_image_id}" ]]; then
    echo "INFO: got latest windows server AMI ID: ${windows_latest_image_id}"
fi
