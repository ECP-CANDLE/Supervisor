#!/bin/bash
set -eu

# CMP-CV TEST SMALL 1

if (( ${#} != 2 ))
then
  echo "usage: test BENCHMARK_NAME SITE"
  exit 1
fi

export MODEL_NAME=$1
SITE=$2

# Self-configure
THIS=$(                realpath $( dirname $0 ) )
CANDLE_PROJECT_ROOT=$( realpath $THIS )
WORKFLOWS_ROOT=$(      realpath $THIS/../.. )
export EMEWS_PROJECT_ROOT

export OBJ_RETURN="val_loss"
CFG_SYS=$THIS/cfg-sys-1.sh

export CANDLE_MODEL_TYPE="BENCHMARKS"
$CANDLE_PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS $THIS/plan-small-1.txt
