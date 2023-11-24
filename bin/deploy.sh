#!/usr/bin/env bash

set -euxo pipefail

nix-build
docker load < result
docker push australia-southeast2-docker.pkg.dev/willmcpherson2/willmcpherson2/willmcpherson2:latest
cat "$(dirname $0)/pull-on-cloud.sh" | gcloud compute ssh willmcpherson2 --command
