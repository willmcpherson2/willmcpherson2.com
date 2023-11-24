#!/usr/bin/env bash

set -euxo pipefail

docker pull australia-southeast2-docker.pkg.dev/willmcpherson2/willmcpherson2/willmcpherson2:latest
docker stop willmcpherson2 || true
docker rm willmcpherson2 || true
docker run -d --name willmcpherson2 -p 80:80 australia-southeast2-docker.pkg.dev/willmcpherson2/willmcpherson2/willmcpherson2:latest
