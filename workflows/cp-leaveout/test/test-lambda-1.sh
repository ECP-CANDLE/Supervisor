#!/bin/bash
set -eu

# CP LEAVEOUT TEST LAMBDA 1

SCRIPT=$( basename $0 .sh )

usage()
{
  echo "Usage: $0 SITE EXPID WORKFLOW_ARGS"
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

SCRIPT=$( basename $0 .sh )

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

# Data files
CANDLE_DATA=$HOME/CANDLE_DATA_DIR/ChallengeProblem/top21_2020Jul
PLAN_JSON=$CANDLE_DATA/plangen_cell703-p4_drug1492-p1.json # NEW 2022-07
# DATAFRAME_CSV=$CANDLE_DATA/topN.uno.h5
# DATAFRAME_CSV=$CANDLE_DATA/top21.h5  # 2022-07
# DATAFRAME_CSV=$CANDLE_DATA/top21-cleaned-dd.h5  # NEW 2022-10
DATAFRAME_CSV=$CANDLE_DATA/top21-cleaned.h5
# DATAFRAME_CSV=$CANDLE_DATA/top21_uno_v2.h5
BENCHMARK_DATA=$CANDLE_DATA

# What to return from the objective function (Keras model)
# val_loss (default), loss, and val_corr are supported
# export OBJ_RETURN="val_loss"
export OBJ_RETURN="loss"

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

echo "$SCRIPT: OK"

# Local Variables:
# c-basic-offset: 2;
# End:
