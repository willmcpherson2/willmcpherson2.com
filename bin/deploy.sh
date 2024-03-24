#!/usr/bin/env bash

set -euxo pipefail

result=$(nix-build)
nix store sign -k private.pem "$result"
nix-copy-closure --to will@willmcpherson2.com?remote-program=/nix/var/nix/profiles/default/bin/nix-store "$result"
ssh will@willmcpherson2.com "sudo $result/bin/willmcpherson2.com"
