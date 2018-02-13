$ErrorActionPreference = “Stop”;
trap { $host.SetShouldExit(1) }

cd csi-local-volume-release

$env:GOPATH=$PWD
$env:PATH="$PWD/bin;$env:PATH"

go install github.com/onsi/ginkgo/ginkgo

cd src/github.com/jeffpak/local-node-plugin
ginkgo -r -keepGoing -p -trace -randomizeAllSpecs -progress --race
