#!/bin/bash
set -eu

# TEST UPF INFER

if (( ${#} != 2 ))
then
  echo "usage: test SITE UPF"
  exit 1
fi

SITE=$1
UPF=$2

# Self-configure
THIS=$(               cd $( dirname $0 ) ; /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/..        ; /bin/pwd )
WORKFLOWS_ROOT=$(     cd $THIS/../..     ; /bin/pwd )
export EMEWS_PROJECT_ROOT

export MODEL_NAME="infer"
CFG_SYS=$THIS/cfg-sys-1.sh

# Set this to a large writable location
export EXPERIMENTS=/project/projectdirs/m2924/wozniak/Public/data/experiments

$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS $UPF
