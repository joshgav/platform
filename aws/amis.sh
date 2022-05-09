#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

amis_file_path=${this_dir}/amis.json

echo ""
echo "INFO: getting latest amis list..."
aws ec2 describe-images --output json > ${amis_file_path}

windows_latest_image_id=$(cat ${amis_file_path} | \
    jq -r '[ .Images[] | 
                select((.PlatformDetails? | match("Windows")) 
                   and (.Architecture? | match("x86_64")) 
                   and (.Name | match("^Windows_Server-2022-English-Full-ContainersLatest"))) ] | 
                      max_by(.CreationDate) | 
                         .ImageId'
    )
if [[ -n "${windows_latest_image_id}" ]]; then
   echo "INFO: got latest windows server AMI ID: ${windows_latest_image_id}"
fi

rhel_image_id=$(cat ${amis_file_path} | \
                  jq -r '.Images[] | select(.Name == "RHEL-8.5_HVM-20220127-x86_64-3-Hourly2-GP2") | .ImageId')
if [[ -n "${rhel_image_id}" ]]; then
   echo "INFO: got RHEL 8.5 AMI ID: ${rhel_image_id}"
fi
