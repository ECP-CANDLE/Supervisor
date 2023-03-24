#! /usr/bin/env bash
set -eu

# CMP-CV WORKFLOW SH

# Autodetect this workflow directory
export CANDLE_PROJECT_ROOT=$( realpath $( dirname $0 )/.. )
export WORKFLOWS_ROOT=$(      realpath $CANDLE_PROJECT_ROOT/..  )

SCRIPT_NAME=$(basename $0)

# Source some utility functions used in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

usage()
{
  echo "CMP-CV: usage: workflow.sh SITE EXPID CFG_SYS PLAN"
}

if (( ${#} != 5 ))
then
  usage
  exit 1
fi

if ! {
  # Sets SITE
  # Sets EXPID, TURBINE_OUTPUT
  # Sets CFG_SYS
  # PLAN is the hyperparameter list file
  get_site    $1               && \
  get_expid   $2               && \
  get_cfg_sys $3               && \
  UPF=$4
  MODELS=$5
 }
then
  usage
  exit 1
fi

source_site env   $SITE
source_site sched $SITE

# Set up PYTHONPATH for model
source $WORKFLOWS_ROOT/common/sh/set-pythonpath.sh
export PYTHONPATH="${PYTHONPATH}:/homes/ac.gpanapitiya/ccmg-mtg/models/to_Candle/DrugCell"
export PYTHONPATH="${PYTHONPATH}:/homes/ac.gpanapitiya/ccmg-mtg/models/to_Candle/SWnet"

log_path PYTHONPATH

export TURBINE_JOBNAME="CMP_${EXPID}"

export MODEL_SH=${MODEL_SH:-$WORKFLOWS_ROOT/common/sh/model.sh}
export BENCHMARK_TIMEOUT
PLAN="PLAN_NOT_DEFINED"
CMD_LINE_ARGS=( -expid=$EXPID
                -benchmark_timeout=$BENCHMARK_TIMEOUT
                -plan=$PLAN
                -models=$MODELS
                -gparams=$UPF
              )

USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

# Copy settings to TURBINE_OUTPUT for provenance
cp $CFG_SYS $TURBINE_OUTPUT

# Make run directory in advance to reduce contention
mkdir -pv $TURBINE_OUTPUT/run

cp -v $UPF $TURBINE_OUTPUT

# TURBINE_STDOUT="$TURBINE_OUTPUT/out-%%r.txt"
TURBINE_STDOUT=

if [[ ${CANDLE_DATA_DIR:-} == "" ]]
then
  abort "cmp-cv workflow.sh: Set CANDLE_DATA_DIR!"
fi

export CANDLE_IMAGE=${CANDLE_IMAGE:-}
# export $SWIFT_IMPL=container

which swift-t

swift-t -n $PROCS \
        -o $TURBINE_OUTPUT/workflow.tic \
        ${MACHINE:-} \
        -p \
        -I $WORKFLOWS_ROOT/common/swift \
        -i obj_$SWIFT_IMPL \
        -e BENCHMARKS_ROOT \
        -e CANDLE_PROJECT_ROOT \
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
