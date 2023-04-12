#!/bin/bash
set -eu

# UQ NOISE TEST 1

usage()
{
  echo "Usage: test SITE RUN_DIR(optional)"
  echo "       RUN_DIR is optional, use -a for automatic"
}

RUN_DIR=""
if (( ${#} == 2 ))
then
	RUN_DIR=$2
elif (( ${#} == 1 )) # test-all uses this
then
	RUN_DIR="-a"
else
        usage
        exit 1
fi

export MODEL_NAME=nt3
SITE=$1

# Self-configure
THIS=$( cd $( dirname $0 ) && /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/.. && /bin/pwd )
export EMEWS_PROJECT_ROOT
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. && /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh

# Select configurations
export CFG_SYS=$THIS/cfg-sys-1.sh
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
$EMEWS_PROJECT_ROOT/swift/workflow-gauss-abs.sh $SITE $RUN_DIR $CFG_SYS $CFG_PRM $MODEL_NAME

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
