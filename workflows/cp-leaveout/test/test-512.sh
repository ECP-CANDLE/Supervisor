#!/bin/bash
set -eu

# CP LEAVEOUT TEST 512

usage()
{
  echo "Usage: test SITE EXPID WORKFLOW_ARGS"
}

if (( ${#} < 2 ))
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
export CFG_SYS=$THIS/cfg-sys-512.sh
export CFG_PRM=$THIS/cfg-prm-1.sh

# # Data files
# # PLAN_JSON=$EMEWS_PROJECT_ROOT/plangen_cell8-p2_drug8-p2.json
# SCRATCH=/gpfs/alpine/med106/scratch/hsyoo
# CANDLE_DATA=$SCRATCH/Milestone13
# PLAN_JSON=$CANDLE_DATA/plangen_cell1593-p4_drug1779-p1.json
# DATAFRAME_CSV=$CANDLE_DATA/top_21.res_reg.cf_rnaseq.dd_dragon7.labled.csv
# BENCHMARK_DATA=$SCRATCH/Milestone13/Benchmarks/Pilot1/Uno

# Data files
# PLAN_JSON=$EMEWS_PROJECT_ROOT/plangen_cell8-p2_drug8-p2.json
# SCRATCH=/gpfs/alpine/med106/scratch/hsyoo
SCRATCH=/gpfs/alpine/med106/scratch/wozniak
# SCRATCH=/usb2/wozniak
# CANDLE_DATA=$SCRATCH/CANDLE-Data/Milestone-13
CANDLE_DATA=$SCRATCH/CANDLE-Data/ChallengeProblem/top21_2020Jul
# CANDLE_DATA=$SCRATCH/CANDLE-Data/ChallengeProblem/old
# PLAN_JSON=$CANDLE_DATA/plangen_cell1593-p4_drug1779-p1.json
# DATAFRAME_CSV=$CANDLE_DATA/top_21.res_reg.cf_rnaseq.dd_dragon7.labled.csv
# DATAFRAME_CSV=$CANDLE_DATA/top_21.res_reg.cf_rnaseq.dd_dragon7.labled.feather
# DATAFRAME_CSV=$CANDLE_DATA/top_21.res_reg.cf_rnaseq.dd_dragon7.labled.hdf5
PLAN_JSON=$CANDLE_DATA/plangen_cell703-p4_drug1492-p1-u.json # 2022-07
# PLAN_JSON=$CANDLE_DATA/plangen_CELL2917-p4_DRUG2148-p4.json # 2023-02
# PLAN_JSON=/gpfs/alpine/med106/proj-shared/brettin/Supervisor/workflows/cp-leaveout/plangen_CELL2917-p4_DRUG2148-p4.json
# DATAFRAME_CSV=$CANDLE_DATA/top21.h5  # 2022-07
DATAFRAME_CSV=$CANDLE_DATA/top21-cleaned-dd.h5  # NEW 2022-10
# BENCHMARK_DATA=$SCRATCH/proj/Benchmarks/Pilot1/Uno
# BENCHMARK_DATA=$HOME/proj/Benchmarks/Pilot1/Uno
BENCHMARK_DATA=$CANDLE_DATA
# PROJ_SHARED=/gpfs/alpine/med106/proj-shared/wozniak
# BENCHMARK_DATA=$PROJ_SHARED/proj/Benchmarks/Pilot1/Uno

# What to return from the objective function (Keras model)
# val_loss (default), loss, and val_corr are supported
# export OBJ_RETURN="val_loss"
export OBJ_RETURN="loss"

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

if [[ ! -e $BENCHMARK_DATA/cache ]]
then
  echo "$0: The cache does not exist: $BENCHMARK_DATA/cache"
  echo "$0: Use mkdir to create this directory"
  exit 1
fi

# Submit job
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE $RUN_DIR $CFG_SYS $CFG_PRM \
                                      $MODEL_NAME $WORKFLOW_ARGS       \
                                      --plan_json=$PLAN_JSON           \
                                      --dataframe_csv=$DATAFRAME_CSV   \
                                      --benchmark_data=$BENCHMARK_DATA

# Check job output
TURBINE_OUTPUT=$( readlink turbine-output )
OUTPUT=turbine-output/output.txt
WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )

# Wait for job
# queue_wait
exit

SCRIPT=$( basename $0 .sh )
check_output "RESULTS:"     $OUTPUT $WORKFLOW $SCRIPT $JOBID
check_output "EXIT CODE: 0" $OUTPUT $WORKFLOW $SCRIPT $JOBID

echo "$SCRIPT: SUCCESS"

# Local Variables:
# c-basic-offset: 2;
# End:
