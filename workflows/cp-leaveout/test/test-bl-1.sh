#!/bin/bash
set -eu

# CP LEAVEOUT BASELINE TEST 1

usage()
{
  echo "Usage: test SITE EXPID WORKFLOW_ARGS"
}

if (( ${#} == 0 ))
then
  usage
  exit 1
fi

# Self-configure
THIS=$( cd $( dirname $0 ) && /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/.. && /bin/pwd )
export EMEWS_PROJECT_ROOT
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. && /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh

SITE=$1
RUN_DIR=$2
shift 2
WORKFLOW_ARGS=$*

export MODEL_NAME=uno # nt3

# Select configurations
export CFG_SYS=$THIS/cfg-sys-1.sh
export CFG_PRM=$THIS/cfg-prm-1.sh

# Data files
# PLAN_JSON=$EMEWS_PROJECT_ROOT/plangen_cell8-p2_drug8-p2.json
# DATAFRAME_CSV=/usb1/wozniak/CANDLE-Benchmarks-Data/top21_dataframe_8x8.csv

# Data files
# SUMMIT:
# PLAN_JSON=$EMEWS_PROJECT_ROOT/plangen_cell8-p2_drug8-p2.json
# SCRATCH=/gpfs/alpine/med106/scratch/hsyoo
SCRATCH=/gpfs/alpine/med106/scratch/wozniak
# SCRATCH=/usb2/wozniak
CANDLE_DATA=$SCRATCH/CANDLE-Data/ChallengeProblem
PLAN_JSON=$CANDLE_DATA/plangen_cell1593-p4_drug1779-p1.json
# DATAFRAME_CSV=$CANDLE_DATA/top_21.res_reg.cf_rnaseq.dd_dragon7.labled.csv
DATAFRAME_CSV=$CANDLE_DATA/top_21.res_reg.cf_rnaseq.dd_dragon7.labeled.hdf5
BENCHMARK_DATA=$SCRATCH/proj/Benchmarks/Pilot1/Uno
# BENCHMARK_DATA=$HOME/proj/Benchmarks/Pilot1/Uno

# What to return from the objective function (Keras model)
# val_loss (default) and val_corr are supported
export OBJ_RETURN="val_loss"

if [[ $SITE == "theta" ]]
then
  export WAIT=1
fi

for f in $DATAFRAME_CSV
do
  if [[ ! -f $f ]]
  then
    abort "$0: does not exist: $f"
  fi
done

export TURBINE_LAUNCH_OPTIONS="-g6 -c42 -a1 -b packed:42"

# Submit job
export WORKFLOW_SWIFT=baseline-error.swift
# set -x
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE $RUN_DIR $CFG_SYS $CFG_PRM \
                                      $MODEL_NAME none $WORKFLOW_ARGS  \
                                      --dataframe_csv=$DATAFRAME_CSV   \
                                      --benchmark_data=$BENCHMARK_DATA \

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
