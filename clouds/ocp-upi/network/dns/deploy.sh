#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

coredns_ver=1.8.6

if [[ ! type -P coredns &> /dev/null ]]; then
    temp_dir=$(mktemp -d)
    pushd ${temp_dir}
    curl -sSLo coredns.tgz https://github.com/coredns/coredns/releases/download/v${coredns_ver}/coredns_${coredns_ver}_linux_amd64.tgz
    tar -xzf coredns.tgz
    cp coredns /usr/bin/coredns
    popd
fi

echo "coredns -version"
coredns -version

echo "installing systemd files from https://github.com/coredns/deployment/tree/master/systemd"

curl -sSLo /usr/lib/systemd/system/coredns.service https://raw.githubusercontent.com/coredns/deployment/master/systemd/coredns.service
curl -sSLo /usr/lib/sysusers.d/coredns-sysusers.conf https://raw.githubusercontent.com/coredns/deployment/master/systemd/coredns-sysusers.conf
curl -sSLo /usr/lib/tmpfiles.d/coredns-tmpfiles.conf https://raw.githubusercontent.com/coredns/deployment/master/systemd/coredns-tmpfiles.conf

echo "copying local files"
cp ${this_dir}/Corefile /etc/coredns/Corefile
cp ${this_dir}/openshift.lab.zone /etc/coredns/openshift.lab.zone
