#!/usr/bin/env bash

set -euxo pipefail

nix-store --generate-binary-cache-key willmcpherson2.com private.pem public.pem

conf=$(
cat << EOF
build-users-group = nixbld
trusted-public-keys = $(cat public.pem)
trusted-users = root will
EOF
)

ssh will@willmcpherson2.com << EOF
echo "$conf" | sudo tee /etc/nix/nix.conf
sudo systemctl restart nix-daemon
EOF
