#!/usr/bin/env bash

set -euxo pipefail

cat "$(dirname $0)/setup-on-cloud.sh" | gcloud compute ssh willmcpherson2 --command
