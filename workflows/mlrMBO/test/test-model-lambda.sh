#!/bin/bash
set -eu

# MLRMBO TEST NIGHTLY

usage()
{
  echo "Usage: test BENCHMARK_NAME SITE RUN_DIR EXPERIMENT_PARAMATER_FILE"
  echo "       RUN_DIR is optional, use -a for automatic"
}

RUN_DIR=""
if (( ${#} == 4 ))
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
export CFG_SYS=$THIS/cfg-sys-nightly.sh
export CFG_PRM=$THIS/cfg-prm-nightly.sh
export PARAM_SET_FILE=$4

# Move experiment config in place - is R file wtf
if [ -f $PARAM_SET_FILE ] 
then
	echo $WORKFLOWS_ROOT
	echo $EMEWS_PROJECT_ROOT
	FNAME=$( basename $PARAM_SET_FILE )
	cp $PARAM_SET_FILE  $EMEWS_PROJECT_ROOT/data/$FNAME
	PARAM_SET_FILE=$FNAME
fi


# Specify the R file for This file must be present in the $EMEWS_PROJECT_ROOT/R
export R_FILE=mlrMBO-mbo.R

# What to return from the objective function (Keras model)
# val_loss (default) and val_corr are supported
export MODEL_RETURN="val_loss"

if [[ $SITE == "theta" ]]
then
  export WAIT=1
fi

export CANDLE_MODEL_TYPE="SINGULARITY"
export CANDLE_IMAGE="/software/improve/images/GraphDRP.sif"
export INIT_PARAMS_FILE="/software/improve/graphdrp_default_model.txt"

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
