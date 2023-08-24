#! /usr/bin/env bash

curl -sSL https://mirror.openshift.com/pub/rhacs/assets/latest/bin/linux/roxctl -o ~/.local/bin/roxctl
chmod +x ~/.local/bin/roxctl

echo "INFO: roxctl version:"
roxctl version
