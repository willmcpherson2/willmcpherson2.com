#!/usr/bin/env bash

set -euxo pipefail

nix-build
docker load < result
gcloud compute ssh willmcpherson2 --command "docker system prune -f -a"
gcloud artifacts docker images delete asia-east1-docker.pkg.dev/willmcpherson2/willmcpherson2/willmcpherson2:latest
docker push asia-east1-docker.pkg.dev/willmcpherson2/willmcpherson2/willmcpherson2:latest
gcloud compute instances update-container willmcpherson2
