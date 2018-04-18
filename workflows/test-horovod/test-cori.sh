#!/bin/bash -l
set -eu

# TEST CORI SH
# Simple Swift/T+Python+Horovod tests on Cori
# Use this with Swift scripts in sanity/

if (( ${#} != 1 ))
then
  echo "Provide a Swift script!"
  exit 1
fi
SWIFT_SCRIPT=$1

module load java gcc
module load tensorflow/intel-head

PATH=$HOME/Public/sfw/login/swift-t-2018-04-16/stc/bin:$PATH
# PATH=/usr/common/software/tensorflow/tensorflow/1.4.0rc0/bin:$PATH

swift-t -v
which python
echo PP  ${PYTHONPATH:-}
echo PUB $PYTHONUSERBASE

swift-t $SWIFT_SCRIPT
