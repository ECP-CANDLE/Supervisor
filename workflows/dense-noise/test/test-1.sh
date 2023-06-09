#!/bin/bash
set -eu

# DENSE NOISE TEST 1

usage()
{
  echo "Usage: test MODEL_NAME SITE RUN_DIR"
  echo "       RUN_DIR: use -a for automatic"
}

RUN_DIR=""
if (( ${#} == 3 ))
then
  export MODEL_NAME=$1
  SITE=$2
  RUN_DIR=$3
else
  usage
  exit 1
fi

# Self-configure
THIS=$( cd $( dirname $0 ) && /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/.. && /bin/pwd )
export EMEWS_PROJECT_ROOT
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. && /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh
SCRIPT=$( basename $0 .sh )

# Select configurations
export CFG_SYS=$THIS/cfg-sys-small.sh
# export CFG_SYS=$THIS/cfg-sys-big.sh
export CFG_PRM=$THIS/cfg-prm-1.sh

# What to return from the objective function (Keras model)
# val_loss (default) and val_corr are supported
export MODEL_RETURN="val_loss"

export CANDLE_MODEL_TYPE="BENCHMARKS"

if [[ $SITE == "theta" ]]
then
  export WAIT=1
fi

# Submit job
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE $RUN_DIR $CFG_SYS $CFG_PRM $MODEL_NAME

echo "$SCRIPT: OK"

# Local Variables:
# c-basic-offset: 2;
# End:
