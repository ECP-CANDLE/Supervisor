#!/bin/bash
set -eu

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

# Select configurations
CFG_SYS=$THIS/cfg-sys-1.sh
CFG_PRM=$THIS/cfg-prm-1.sh

# Submit job
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS $CFG_PRM

# Wait for job
TURBINE_OUTPUT=$( cat turbine-directory.txt )
JOBID=$( cat $TURBINE_OUTPUT/jobid.txt )
queue_wait $SITE $JOBID

# Check job output
OUTPUT=$TURBINE_OUTPUT/output.txt
WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )
SCRIPT=$( basename $0 .sh )
check_output "val_loss: 16.1181" $OUTPUT $WORKFLOW $SCRIPT $JOBID

echo "$SCRIPT: SUCCESS"
