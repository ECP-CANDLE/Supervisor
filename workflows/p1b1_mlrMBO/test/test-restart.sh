#!/bin/bash
set -eu

# P3B1 TEST 1

if (( ${#} != 1 ))
then
  echo "usage: test SITE"
  exit 1
fi

SITE=$1

# Self-configure
THIS=$( cd $( dirname $0 ) && /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/.. && /bin/pwd )
export EMEWS_PROJECT_ROOT
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. && /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh

#Two variables for restarting from existing results, will be removed with more development for automatic setup
export RESTART_FILE=$EMEWS_PROJECT_ROOT/test/restart-test-p1b1.csv
export RESTART_NUMBER=2

# Select configurations
export CFG_SYS=$THIS/cfg-sys-1.sh
export CFG_PRM=$THIS/cfg-prm-restart.sh

# Specify the R file for This file must be present in the $EMEWS_PROJECT_ROOT/R
export R_FILE=mlrMBO1.R

export OBJ_PARAM="val_loss"

# Submit job
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS $CFG_PRM

# Wait for job
queue_wait

# Check job output
OUTPUT=$TURBINE_OUTPUT/output.txt
WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )
SCRIPT=$( basename $0 .sh )
check_output "learning_rate" $OUTPUT $WORKFLOW $SCRIPT $JOBID

echo "$SCRIPT: SUCCESS"
