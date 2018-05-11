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
# module load tensorflow/intel-head
module load python/2.7-anaconda-4.4

PATH=$HOME/Public/sfw/login/swift-t-2018-04-16/stc/bin:$PATH

# export PYTHONPATH=$HOME/.local/lib/python2.7/site-packages

# swift-t -v
# which python
# echo PP  ${PYTHONPATH:-}
# echo PUB $PYTHONUSERBASE

export SWIFT_PATH=$PWD

TIC=${SWIFT_SCRIPT%.swift}.tic
swift-t -u -o $TIC $SWIFT_SCRIPT
