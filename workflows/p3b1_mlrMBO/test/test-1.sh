#!/bin/sh

if (( ${#} != 1 ))
then
  echo "usage: test SITE"
  exit 1
fi

SITE=$1

# Self-configure
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
echo $EMEWS_PROJECT_ROOT
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh
WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )
SCRIPT=$( basename $0 .sh )

# Submit job
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a

# Wait for job
TURBINE_OUTPUT=$( cat turbine-directory.txt )
JOBID=$( cat $TURBINE_OUTPUT/jobid.txt )
queue_wait $SITE $JOBID

# Check job
OUTPUT=$TURBINE_OUTPUT/output.txt
check_output "val_loss: 16.1181" $OUTPUT $WORKFLOW $SCRIPT $JOBID
