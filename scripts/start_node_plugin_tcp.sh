#!/bin/bash

set -x

cd `dirname $0`

pkill -f csi_local_node

mkdir -p ~/csi_plugins
rm ~/csi_plugins/csi_local_node.*

~/csi_local_node &

