#!/bin/bash
set -eu

# GA TEST BMK
# Runs any CANDLE Benchmark in using MODEL_IMPL="app"

usage()
{
  echo "Usage: test BENCHMARK_NAME SITE RUN_DIR(optional)"
  echo "       RUN_DIR is optional, use -a for automatic"
}

RUN_DIR=""
if (( ${#} == 3 ))
then
	RUN_DIR=$3
elif (( ${#} == 2 )) # test-all uses this
then
	RUN_DIR="-a"
else
        usage
        exit 1
fi

export MODEL_NAME=$1
SITE=$2

# Self-configure
THIS=$( cd $( dirname $0 ) && /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/.. && /bin/pwd )
export EMEWS_PROJECT_ROOT
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. && /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh

# Select configurations
export CFG_SYS=$THIS/cfg-sys-1.sh
export CFG_PRM=$THIS/cfg-prm-1.sh
# export PARAM_SET_FILE=graphdrp_param_space_ga.json

# The python GA model exploration algorithm
export GA_FILE=deap_ga.py

# What to return from the objective function (Keras model)
# val_loss (default) and val_corr are supported
export MODEL_RETURN="val_loss"

export CANDLE_MODEL_TYPE="BENCHMARKS"
export CANDLE_IMAGE=NONE
export CANDLE_MODEL_IMPL="app"

# Submit job
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE $RUN_DIR $CFG_SYS $CFG_PRM \
                                      $MODEL_NAME \
                                      $CANDLE_MODEL_TYPE $CANDLE_IMAGE

# Check job output
TURBINE_OUTPUT=$( readlink turbine-output )
echo $TURBINE_OUTPUT
OUTPUT=$TURBINE_OUTPUT/output.txt
WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )

SCRIPT=$( basename $0 .sh )
#check_output "learning_rate" $OUTPUT $WORKFLOW $SCRIPT $JOBID

echo "$SCRIPT: SUCCESS"

# Local Variables:
# c-basic-offset: 2;
# End:
