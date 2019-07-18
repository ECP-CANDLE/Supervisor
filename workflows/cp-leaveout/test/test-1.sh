#!/bin/bash
set -eu

# CP LEAVEOUT TEST 1

usage()
{
  echo "Usage: test SITE EXPID WORKFLOW_ARGS"
}

if (( ${#} == 0 ))
then
  usage
  exit 1
fi

SITE=$1
RUN_DIR=$2
shift 2
WORKFLOW_ARGS=$*

export MODEL_NAME=uno # nt3

# Self-configure
THIS=$( cd $( dirname $0 ) && /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/.. && /bin/pwd )
export EMEWS_PROJECT_ROOT
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. && /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh

# Select configurations
export CFG_SYS=$THIS/cfg-sys-1.sh
export CFG_PRM=$THIS/cfg-prm-1.sh

# What to return from the objective function (Keras model)
# val_loss (default) and val_corr are supported
export OBJ_RETURN="val_loss"

if [[ $SITE == "theta" ]]
then
  export WAIT=1
fi

# Submit job
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE $RUN_DIR $CFG_SYS $CFG_PRM \
                                      $MODEL_NAME $WORKFLOW_ARGS

# Wait for job
queue_wait

# Check job output
OUTPUT=turbine-output/output.txt
WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )

SCRIPT=$( basename $0 .sh )
check_output "RESULTS:" $OUTPUT $WORKFLOW $SCRIPT $JOBID

echo "$SCRIPT: SUCCESS"

# Local Variables:
# c-basic-offset: 2;
# End:
