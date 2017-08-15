#!/bin/bash

set -e -x

cd csi-local-volume-release/

export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH

export GOPATH=$PWD
export PATH=$PWD/bin:$PATH

go install github.com/onsi/ginkgo/ginkgo

pushd src/github.com/jeffpak/local-node-plugin
  ginkgo -r -keepGoing -p -trace -randomizeAllSpecs -progress --race "$@"
popd
