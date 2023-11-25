#!/usr/bin/env bash

ssh will@willmcpherson2.com << EOF
set -euxo pipefail
sudo apt-get update
sudo apt-get install curl xz-utils --yes
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
EOF
