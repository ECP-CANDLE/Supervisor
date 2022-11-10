#!/bin/bash
set -eu

echo "Usage test-1.sh BECHMARK_NAME SITE RUN_DIR(optional, -a=automatic)"

RUN_DIR=""

if (( ${#} > 2 ))
then
	echo "Run directory specified."
	RUN_DIR=$3
elif (( ${#} == 2 )) # test-all uses this
then
	echo "Automatically assigning run directory in ../experiments folder"
	RUN_DIR="-a"
else
	echo "Usage test SITE RUN_DIR(optional)"
	exit 1
fi

echo "Run directory for this case: ", $RUN_DIR
export MODEL_NAME=$1
SITE=$2

# Self-configure
THIS=$( cd $( dirname $0 ) && /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/.. && /bin/pwd )
export EMEWS_PROJECT_ROOT
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. && /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh

# Select configurations
export CFG_SYS=$THIS/cfg-sys-30.sh
export CFG_PRM=$THIS/cfg-prm-30.sh

# Specify the R file for This file must be present in the $EMEWS_PROJECT_ROOT/R
export R_FILE=mlrMBO1.R

#val_loss (default) and val_corr are supported
export OBJ_PARAM="val_loss"


# Submit job
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE $RUN_DIR $CFG_SYS $CFG_PRM

# Wait for job
queue_wait

cp $0 $TURBINE_OUTPUT
# Check job output
OUTPUT=$TURBINE_OUTPUT/output.txt
WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )


SCRIPT=$( basename $0 .sh )
check_output "learning_rate" $OUTPUT $WORKFLOW $SCRIPT $JOBID

echo "$SCRIPT: SUCCESS"
