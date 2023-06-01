#! /usr/bin/env bash

OS=linux
VERSION=$(curl -s https://api.github.com/repos/noobaa/noobaa-operator/releases/latest | jq -r '.name')
curl -LO https://github.com/noobaa/noobaa-operator/releases/download/$VERSION/noobaa-$OS-$VERSION
chmod +x noobaa-$OS-$VERSION

sudo mv noobaa-$OS-$VERSION /usr/local/bin/noobaa
noobaa version
