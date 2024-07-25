#!/bin/bash
set -eu

# TEST GDRP 1 # For GraphDRP

if (( ${#} != 2 ))
then
  echo "usage: test SITE MODEL_NAME"
  exit 1
fi

SITE=$1
export MODEL_NAME=$2

# Self-configure
THIS=$(            cd $( dirname $0 )    && /bin/pwd )
PROJECT_ROOT=$(    cd $THIS/..           && /bin/pwd )
WORKFLOWS_ROOT=$(  cd $PROJECT_ROOT/..   && /bin/pwd )
SUPERVISOR_HOME=$( cd $WORKFLOWS_ROOT/.. && /bin/pwd )

source         $SUPERVISOR_HOME/workflows/common/sh/utils.sh
sv_path_append $SUPERVISOR_HOME/workflows/common/sh

# Job settings
export CANDLE_MODEL_TYPE="SINGULARITY"
export PROCS=4
export PPN=4
export WALLTIME=00:05:00

# Run generic workflow wrapper:
$PROJECT_ROOT/swift/workflow.sh $SITE -a

# We cannot currently wait- we are not settings TURBINE_OUTPUT
# # Wait for job
# queue_wait

# # Check job output
# OUTPUT=$TURBINE_OUTPUT/output.txt
# WORKFLOW=$( basename $PROJECT_ROOT )
# SCRIPT=$(   basename $0 .sh )
# check_output "learning_rate" $OUTPUT $WORKFLOW $SCRIPT $JOBID

# echo "$SCRIPT: SUCCESS"
