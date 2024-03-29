#!/bin/bash
set -eu

# MLRMBO TEST 1

usage()
{
  echo "Usage: test MODEL_NAME SITE RUN_DIR(optional)"
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
# Temporarily hard-coding to graphdrp:
export PARAM_SET_FILE=$THIS/../data/graphdrp_small.R
export CFG_SYS=$THIS/cfg-sys-1.sh
export CFG_PRM=$THIS/cfg-prm-1.sh

# export MODEL_PYTHON_SCRIPT=cc_t29res
# export MODEL_PYTHON_DIR=$HOME/proj/candle_tutorials/Topics/1_migrating_your_DNN_to_candle

# Specify the R file for This file must be present in the $EMEWS_PROJECT_ROOT/R
export R_FILE=mlrMBO-ils.R

# What to return from the objective function (Keras model)
# val_loss (default) and val_corr are supported
export MODEL_RETURN="val_loss"

if [[ $SITE == "theta" ]]
then
  export WAIT=1
fi

# Submit job
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE $RUN_DIR $CFG_SYS $CFG_PRM $MODEL_NAME

# Wait for job
queue_wait

# Check job output
OUTPUT=$TURBINE_OUTPUT/output.txt
WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )

SCRIPT=$( basename $0 .sh )
# Note that the following line is essentially hardcoding a gParameter (learning_rate) that may or may not be an actual model parameter
#check_output "learning_rate" $OUTPUT $WORKFLOW $SCRIPT $JOBID

echo "$SCRIPT: SUCCESS"

# Local Variables:
# c-basic-offset: 2;
# End:
