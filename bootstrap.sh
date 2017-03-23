#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

err_exit() {
    echo "$1" 1>&2
    exit 1
}

echo "Bootstrapping carthage..."
carthage bootstrap --no-build || err_exit "Failed to bootstrap carthage"
