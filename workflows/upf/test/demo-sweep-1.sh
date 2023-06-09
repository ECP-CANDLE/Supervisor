#!/bin/bash
set -eu

# DEMO SWEEP 1

if (( ${#} != 2 ))
then
  echo "usage: test BENCHMARK_NAME SITE"
  exit 1
fi

export MODEL_NAME=$1
SITE=$2

# Self-configure
THIS=$(               cd $( dirname $0 ) ; /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/..        ; /bin/pwd )
WORKFLOWS_ROOT=$(     cd $THIS/../..     ; /bin/pwd )
export EMEWS_PROJECT_ROOT

export OBJ_RETURN="val_loss"
CFG_SYS=$THIS/cfg-sys-1.sh

$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS $THIS/demo-1.json
