#!/bin/bash
set -eu

# UQ NOISE TEST 1

usage()
{
  echo "Usage: test SITE RUN_DIR MODEL_NAME"
  echo "       RUN_DIR: use -a for automatic"
}

RUN_DIR=""
if (( ${#} == 3 ))
then
  SITE=$1
  RUN_DIR=$2
  export MODEL_NAME=$3
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

# Select configurations
export CFG_SYS=$THIS/cfg-sys-small.sh
# export CFG_SYS=$THIS/cfg-sys-big.sh
export CFG_PRM=$THIS/cfg-prm-1.sh

# What to return from the objective function (Keras model)
# val_loss (default) and val_corr are supported
export OBJ_RETURN="val_loss"

export CANDLE_MODEL_TYPE="BENCHMARKS"

if [[ $SITE == "theta" ]]
then
  export WAIT=1
fi

# Submit job
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE $RUN_DIR $CFG_SYS $CFG_PRM $MODEL_NAME

# Wait for job
TURBINE_OUTPUT=$( readlink turbine-output )
queue_wait

# Check job output
OUTPUT=$TURBINE_OUTPUT/output.txt
WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )

SCRIPT=$( basename $0 .sh )

echo "$SCRIPT: SUCCESS"

# Local Variables:
# c-basic-offset: 2;
# End:
