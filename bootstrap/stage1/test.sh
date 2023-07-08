#!/bin/bash

set -e

. .config.sh

echo "
roots   : $RLX
target  : $RLXOS_TGT
arch    : $RLXOS_ARCH
host    : $RLXOS_HOST
user    : $(whoami)

sources : $RLXOS_SRC_DIR
build   : $RLXOS_BUILD_DIR 
"