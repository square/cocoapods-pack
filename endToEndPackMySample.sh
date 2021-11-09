#!/bin/bash

# Compiles and runs CLIConsumer mac app, which uses the MySample pod and ensures the binary version of MySample works end-to-end.

set -e
set -x

rm -rf out/
echo Building MySample...
bundle exec ruby local_pod.rb pack --allow-warnings samples/MySample/MySample.podspec --out-dir=out https://example.com --no-repo-update --use-static-frameworks --skip-platforms=watchos --skip-validation $@

echo Building CLIConsumer, which uses MySample pod
./samples/CLIConsumer/build.sh
