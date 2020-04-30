#!/bin/bash
set -eu

# ASYNC TEST 1

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
echo "EMEWS_PROJECT_ROOT: $EMEWS_PROJECT_ROOT"
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. && /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh

# Select configurations
export CFG_SYS=$THIS/cfg-sys-1.sh
export CFG_PRM=$THIS/cfg-prm-1.sh

export TURBINE_MPI_THREAD=1
export MPICH_MAX_THREAD_SAFETY=multiple

# Specify the R file for This file must be present in the $EMEWS_PROJECT_ROOT/R
#export R_FILE=mlrMBO1.R

# What to return from the objective function (Keras model)
# val_loss (default) and val_corr are supported
export OBJ_RETURN="val_loss"

# Set OBJ_DIR
export OBJ_DIR=$EMEWS_PROJECT_ROOT/obj_folder
export OBJ_MODULE=obj_app

if [[ $SITE == "theta" ]]
then
  export WAIT=1
fi

# Submit job
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE $RUN_DIR $CFG_SYS $CFG_PRM

# Check job output
TURBINE_OUTPUT=$( readlink turbine-output )
OUTPUT=turbine-output/output.txt
WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )

# Wait for job
queue_wait

SCRIPT=$( basename $0 .sh )
check_output "RESULTS:"     $OUTPUT $WORKFLOW $SCRIPT $JOBID
check_output "EXIT CODE: 0" $OUTPUT $WORKFLOW $SCRIPT $JOBID

echo "$SCRIPT: SUCCESS"


# Local Variables:
# c-basic-offset: 2;
# End:
