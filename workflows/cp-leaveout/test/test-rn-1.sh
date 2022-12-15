#!/bin/bash
set -eu

# CP LEAVEOUT ResNet 1

usage()
{
  echo "Usage: test SITE EXPID EPOCH_MODE WORKFLOW_ARGS"
  echo "       EPOCH_MODE is one of the compute_epochs_*.swift modules."
}

if (( ${#} < 3 ))
then
  usage
  exit 1
fi

SITE=$1
RUN_DIR=$2
EPOCH_MODE=$3
shift 3
WORKFLOW_ARGS=$*

export MODEL_PYTHON_DIR=$HOME/proj/ai-apps
export MODEL_NAME=resnet50

# Self-configure
THIS=$( readlink --canonicalize $( dirname $0 ) )
EMEWS_PROJECT_ROOT=$( readlink --canonicalize $THIS/.. )
export EMEWS_PROJECT_ROOT
WORKFLOWS_ROOT=$( readlink --canonicalize $EMEWS_PROJECT_ROOT/.. )
source $WORKFLOWS_ROOT/common/sh/utils.sh

# Select configurations
export CFG_SYS=$THIS/cfg-sys-1.sh
export CFG_PRM=$THIS/cfg-prm-1.sh

# What to return from the objective function (Keras model)
# val_loss (default), loss, and val_corr are supported
# export OBJ_RETURN="val_loss"
export OBJ_RETURN="loss"

if [[ $SITE == "theta" ]]
then
  export WAIT=1
fi

PLAN_JSON=""
DATAFRAME_CSV=""
BENCHMARK_DATA=""

# Submit job
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE $RUN_DIR $CFG_SYS $CFG_PRM \
                                      $MODEL_NAME $EPOCH_MODE $WORKFLOW_ARGS \
                                      --plan_json=$PLAN_JSON           \
                                      --dataframe_csv=$DATAFRAME_CSV   \
                                      --benchmark_data=$BENCHMARK_DATA

# Check job output
TURBINE_OUTPUT=$( readlink turbine-output )
OUTPUT=turbine-output/output.txt
WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )

# Wait for job
# queue_wait
exit

SCRIPT=$( basename $0 .sh )
check_output "RESULTS:"     $OUTPUT $WORKFLOW $SCRIPT $JOBID
check_output "EXIT CODE: 0" $OUTPUT $WORKFLOW $SCRIPT $JOBID

echo "$SCRIPT: SUCCESS"

# Local Variables:
# c-basic-offset: 2;
# End:
