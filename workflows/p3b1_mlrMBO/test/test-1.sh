#!/bin/bash
set -eu

# P3B1 TEST 1

if (( ${#} != 1 ))
then
  echo "usage: test SITE"
  exit 1
fi

SITE=$1

# export RESTART_FILE="/home/jain/Supervisor/workflows/p3b1_mlrMBO/test/restart-12.csv"
# export RESTART_NUMBER=4

# Self-configure
THIS=$( cd $( dirname $0 ) && /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/.. && /bin/pwd )
export EMEWS_PROJECT_ROOT
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. && /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh

# Select configurations
export CFG_SYS=$THIS/cfg-sys-1.sh
export CFG_PRM=$THIS/cfg-prm-1.sh

# Submit job
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS $CFG_PRM 2>&1 > workflow.out

# Wait for job
queue_wait

if (( LOCAL ))
then
  cp workflow.out $TURBINE_OUTPUT/output.txt
fi

# Check job output
if ((  CRAY ))
then
  OUTPUT=$TURBINE_OUTPUT/output.txt.*
else
  OUTPUT=$TURBINE_OUTPUT/output.txt
fi
WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )
SCRIPT=$( basename $0 .sh )
check_output "learning_rate" $OUTPUT $WORKFLOW $SCRIPT $JOBID

echo "$SCRIPT: SUCCESS"
