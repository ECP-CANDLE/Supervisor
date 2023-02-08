#! /usr/bin/env bash
set -eu

# UPF WORKFLOW SH

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( realpath $( dirname $0 )/.. )
export WORKFLOWS_ROOT=$(     realpath $EMEWS_PROJECT_ROOT/..  )

SCRIPT_NAME=$(basename $0)

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

usage()
{
  echo "UNROLLED PARAMETER FILE: usage: workflow.sh SITE EXPID CFG_SYS UPF"
}

if (( ${#} != 4 ))
then
  usage
  exit 1
fi

if ! {
  # Sets SITE
  # Sets EXPID, TURBINE_OUTPUT
  # Sets CFG_SYS
  # UPF is the JSON hyperparameter file
  get_site    $1               && \
  get_expid   $2               && \
  get_cfg_sys $3               && \
  UPF=$4
 }
then
  usage
  exit 1
fi

source_site env   $SITE
source_site sched $SITE

# Set up PYTHONPATH for model
source $WORKFLOWS_ROOT/common/sh/set-pythonpath.sh

log_path PYTHONPATH

export TURBINE_JOBNAME="UPF_${EXPID}"

OBJ_PARAM_ARG=""
if [[ ${OBJ_PARAM:-} != "" ]]
then
  OBJ_PARAM_ARG="--obj_param=$OBJ_PARAM"
fi

export MODEL_SH=${MODEL_SH:-$WORKFLOWS_ROOT/common/sh/model.sh}
export BENCHMARK_TIMEOUT

CMD_LINE_ARGS=( -expid=$EXPID
                -benchmark_timeout=$BENCHMARK_TIMEOUT
                -f=$UPF
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
  abort "upf/workflow.sh: Set CANDLE_DATA_DIR!"
fi

export CANDLE_IMAGE=${CANDLE_IMAGE:-}

which swift-t

swift-t -n $PROCS \
        -o $TURBINE_OUTPUT/workflow.tic \
        ${MACHINE:-} \
        -p -I $EQR -r $EQR \
        -I $WORKFLOWS_ROOT/common/swift \
        -i obj_$SWIFT_IMPL \
        -e BENCHMARKS_ROOT \
        -e EMEWS_PROJECT_ROOT \
        -e MODEL_SH \
        -e SITE \
        -e BENCHMARK_TIMEOUT \
        -e MODEL_NAME=${MODEL_NAME:-MODEL_NULL} \
        -e OBJ_RETURN \
        -e MODEL_PYTHON_SCRIPT=${MODEL_PYTHON_SCRIPT:-} \
        -e TURBINE_MPI_THREAD=${TURBINE_MPI_THREAD:-1} \
        $( python_envs ) \
        -e TURBINE_STDOUT=$TURBINE_STDOUT \
        -e PYTHONUNBUFFERED=1 \
        -e CANDLE_MODEL_TYPE \
        -e CANDLE_IMAGE \
        $EMEWS_PROJECT_ROOT/swift/workflow.swift ${CMD_LINE_ARGS[@]}

# Can provide this to debug Python settings:
#        -e PYTHONVERBOSE=1
# Can provide this if needed to reset PATH:
#        -e PATH=$PATH
