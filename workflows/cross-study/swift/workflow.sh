#! /usr/bin/env bash
set -eu

# CROSS-STUDY WORKFLOW SH

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( realpath $( dirname $0 )/.. )
export WORKFLOWS_ROOT=$(     realpath $EMEWS_PROJECT_ROOT/..  )

SCRIPT_NAME=$(basename $0)

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

usage()
{
  echo "UNROLLED PARAMETER FILE: usage:"
  echo "workflow.sh SITE TEST_SCRIPT    _or_"
  echo "workflow.sh SITE EXPID CFG_SYS CROSS-STUDY"
  echo
  echo "The 2-argument case is used by the supervisor tool."
  echo "The 4-argument case is used for other test cases."
}

if (( ${#} == 0 ))
then
  usage
  exit 1
fi

get_site $1  # Sets SITE

if   (( ${#} == 2 ))
then
  TEST_SCRIPT=$2
  # Sets EXPID.  If EXPID=="" , applies -a
  get_expid ${EXPID:--a}
  source_cfg -v $TEST_SCRIPT
elif (( ${#} == 4 ))
then
  get_expid   $2 # Sets EXPID, TURBINE_OUTPUT
  get_cfg_sys $3 # Sets CFG_SYS
  CS=$4         # The JSON hyperparameter file
else
  usage
  exit 1
fi

if [[ ${CS:-} == "" ]]
then
  echo "CS workflow.sh: set CS!"
  exit 1
fi
if ! find_cfg $CS
then
  crash "Could not find CS: $CS"
fi
CS=$REPLY

source_site env   $SITE
source_site sched $SITE

# Set up PYTHONPATH for model
source $WORKFLOWS_ROOT/common/sh/set-pythonpath.sh

log_path PYTHONPATH

export TURBINE_JOBNAME="${EXPID}"

OBJ_PARAM_ARG=""
if [[ ${OBJ_PARAM:-} != "" ]]
then
  OBJ_PARAM_ARG="--obj_param=$OBJ_PARAM"
fi

# Miscellaneous defaults:
export MODEL_SH=${MODEL_SH:-$WORKFLOWS_ROOT/common/sh/model.sh}
: ${BENCHMARK_TIMEOUT:=-1} ${SH_TIMEOUT:=-1} ${IGNORE_ERRORS:=0}
: ${MODEL_RETURN:=val_loss}
export MODEL_NAME MODEL_RETURN SH_TIMEOUT IGNORE_ERRORS
export CANDLE_MODEL_TYPE BENCHMARK_TIMEOUT

CMD_LINE_ARGS=( -expid=$EXPID
                -benchmark_timeout=$BENCHMARK_TIMEOUT
                -f=$CS
              )

USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

# Copy settings to TURBINE_OUTPUT for provenance
if [[ ${CFG_SYS:-} != "" ]]
then
  cp $CFG_SYS $TURBINE_OUTPUT
fi

# Make run directory in advance to reduce contention
mkdir -pv $TURBINE_OUTPUT/run

cp -v $CS $TURBINE_OUTPUT

# TURBINE_STDOUT="$TURBINE_OUTPUT/out-%%r.txt"
TURBINE_STDOUT=

if [[ ${CANDLE_DATA_DIR:-} == "" ]]
then
  abort "cross-study/workflow.sh: Set CANDLE_DATA_DIR!"
fi

export CANDLE_IMAGE=${CANDLE_IMAGE:-}

which swift-t

swift-t -n $PROCS \
        -o $TURBINE_OUTPUT/workflow.tic \
        ${MACHINE:-} \
        -p \
        -I $WORKFLOWS_ROOT/common/swift \
        -i model_$CANDLE_MODEL_IMPL \
        -e BENCHMARKS_ROOT \
        -e EMEWS_PROJECT_ROOT \
        -e MODEL_SH \
        -e FI_MR_CACHE_MAX_COUNT=0 \
        -e SITE \
        -e BENCHMARK_TIMEOUT \
        -e MODEL_NAME=${MODEL_NAME:-MODEL_NULL} \
        -e OBJ_RETURN \
        -e MODEL_PYTHON_SCRIPT=${MODEL_PYTHON_SCRIPT:-} \
        -e TURBINE_MPI_THREAD=${TURBINE_MPI_THREAD:-1} \
        $( python_envs ) \
        -e TURBINE_STDOUT=$TURBINE_STDOUT \
        -e CANDLE_MODEL_TYPE \
        -e CANDLE_IMAGE \
        $EMEWS_PROJECT_ROOT/swift/workflow.swift ${CMD_LINE_ARGS[@]}

# Can provide this to debug Python settings:
#        -e PYTHONVERBOSE=1
# Can provide this if needed for debugging crashes:
#        -e PYTHONUNBUFFERED=1
# Can provide this if needed to reset PATH:
#        -e PATH=$PATH
