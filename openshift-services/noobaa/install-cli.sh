#! /usr/bin/env bash

OS=linux
ARCH=amd64
VERSION=$(curl -s https://api.github.com/repos/noobaa/noobaa-operator/releases/latest | jq -r '.name')

curl -LO https://github.com/noobaa/noobaa-operator/releases/download/${VERSION}/noobaa-operator-${VERSION}-${OS}-${ARCH}.tar.gz
tar -xvzf noobaa-operator-${VERSION}-${OS}-${ARCH}.tar.gz
chmod +x noobaa-operator
mv noobaa-operator ~/.local/bin/noobaa

noobaa version
