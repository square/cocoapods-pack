#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

rm -rf out/
bundle exec ruby local_pod.rb pack --verbose --allow-warnings samples/MySample/MySample.podspec --out-dir=out https://example.com --no-repo-update $@
