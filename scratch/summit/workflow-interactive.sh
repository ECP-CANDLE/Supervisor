#!/bin/bash
set -eu

# WORKFLOW INTERACTIVE SH

if [[ ${#} != 1 ]]
then
  echo "Specify a Swift script!"
  exit 1
fi
SCRIPT=$1

MED106=/gpfs/alpine/world-shared/med106/
SWIFT=$MED106/wozniak/sw/gcc-6.4.0/swift-t/2020-10-22
PATH=$SWIFT/stc/bin:$PATH

# This is for an interactive run:
export TURBINE_LAUNCHER=jsrun

set -x
swift-t -n $PROCS $SCRIPT
