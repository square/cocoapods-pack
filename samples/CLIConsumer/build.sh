#!/bin/bash

set -e 
set -x
cli_project_path=`dirname $0`

rm -rf $cli_project_path/Pods/ $cli_project_path/build/ $cli_project_path/Podfile.lock

pod install  --project-directory=$cli_project_path --no-repo-update

xcodebuild -workspace $cli_project_path/CLIConsumer.xcworkspace -scheme CLIConsumer -configuration Release -derivedDataPath $cli_project_path/build/

./$cli_project_path/build/Build/Products/Release/CLIConsumer
