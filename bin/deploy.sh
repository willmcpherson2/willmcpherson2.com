#!/usr/bin/env bash

set -euxo pipefail

result=$(nix-build)
nix store sign -k private.pem "$result"
NIX_SSHOPTS='PATH=/nix/var/nix/profiles/default/bin/:$PATH' nix-copy-closure --to will@willmcpherson2.com "$result"
ssh will@willmcpherson2.com "sudo $result/bin/willmcpherson2.com"
