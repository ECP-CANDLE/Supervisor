#!/bin/bash
set -eu

# CP LEAVEOUT CHAIN UPF TEST 1

module unload python

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

export MODEL_NAME=uno #model

# Self-configure
THIS=$( cd $( dirname $0 ) && /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/.. && /bin/pwd )
export EMEWS_PROJECT_ROOT
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. && /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh

# Select configurations
export CFG_SYS=$THIS/$1
export CFG_PRM=$THIS/cfg-prm-1.sh

# Data files
SCRATCH=/gpfs/alpine/med106/scratch/ncollier/job-chain
CANDLE_DATA=$SCRATCH/inputs
PLAN_JSON=$2
UPF_FILE=$3
STAGE=$4
PARENT_STAGE_DIRECTORY=$5
DATAFRAME_CSV=$CANDLE_DATA/top_21.res_reg.cf_rnaseq.dd_dragon7.labled.feather

# Override default of shared parent directory with Supervisor
# This is necessary as benchmarks must be writeable from a
# compute node
export BENCHMARKS_ROOT=$SCRATCH/Benchmarks
BENCHMARK_DATA=$BENCHMARKS_ROOT/Pilot1/Uno

export TURBINE_DIRECTIVE_ARGS+=$6

# What to return from the objective function (Keras model)
# val_loss (default) and val_corr are supported
export OBJ_RETURN="val_loss"

if [[ $SITE == "theta" ]]
then
  export WAIT=1
fi

for f in $DATAFRAME_CSV $PLAN_JSON
do
  if ! [[ -f $f ]]
  then
    echo "$0: does not exist: $f"
    exit 1
  fi
done

# Submit job
$EMEWS_PROJECT_ROOT/swift/cpl-upf-workflow.sh $SITE $RUN_DIR $CFG_SYS $CFG_PRM \
                                      $MODEL_NAME $WORKFLOW_ARGS       \
                                      --plan_json=$PLAN_JSON           \
                                      --dataframe_csv=$DATAFRAME_CSV   \
                                      --benchmark_data=$BENCHMARK_DATA \
                                      --stage=$STAGE \
                                      --parent_stage_directory=$PARENT_STAGE_DIRECTORY \
                                      --f=$UPF_FILE

# Check job output
TURBINE_OUTPUT=$( readlink turbine-output )
OUTPUT=turbine-output/output.txt
WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )

# Wait for job
#queue_wait

SCRIPT=$( basename $0 .sh )
#check_output "RESULTS:"     $OUTPUT $WORKFLOW $SCRIPT $JOBID
#check_output "EXIT CODE: 0" $OUTPUT $WORKFLOW $SCRIPT $JOBID

echo "$SCRIPT: SUCCESS"

# Local Variables:
# c-basic-offset: 2;
# End:
