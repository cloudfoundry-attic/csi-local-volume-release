#!/bin/bash

set -ex

script_path=`realpath $0`
script_dir=`dirname $script_path`

go build -o "$HOME/csi_local_controller" "src/code.cloudfoundry.org/local-controller-plugin/cmd/localcontrollerplugin/main.go"
go build -o "$HOME/csi_local_node" "src/code.cloudfoundry.org/local-node-plugin/cmd/localnodeplugin/main.go"

go get -t github.com/paulcwarren/csi-cert

#=======================================================================================================================
# local-controller-plugin local-node-plugin
#=======================================================================================================================

function cleanup {
  cd $script_dir
  /bin/bash ./stop_controller_plugin_tcp.sh
  /bin/bash ./stop_node_plugin_tcp.sh
  rm -rf $HOME/csi_plugins
}

# TCP TESTS
export FIXTURE_FILENAME=$PWD/scripts/fixtures/local_plugin_cert.json
trap cleanup EXIT
/bin/bash scripts/start_controller_plugin_tcp.sh
/bin/bash scripts/start_node_plugin_tcp.sh
pushd src/github.com/paulcwarren/csi-cert
    ginkgo -r
popd

