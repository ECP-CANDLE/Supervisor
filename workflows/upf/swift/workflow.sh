#! /usr/bin/env bash
set -eu

# UPF WORKFLOW SH

# Autodetect this workflow directory
export THIS=$( realpath $( dirname $0 ) )
export EMEWS_PROJECT_ROOT=$( realpath $( dirname $0 )/.. )
export WORKFLOWS_ROOT=$(     realpath $EMEWS_PROJECT_ROOT/..  )

SCRIPT_NAME=$(basename $0)

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

usage()
{
  echo "UNROLLED PARAMETER FILE: usage:"
  echo "workflow.sh SITE TEST_SCRIPT    _or_"
  echo "workflow.sh SITE EXPID CFG_SYS UPF"
  echo
  echo "The 2-argument case is used by the supervisor tool."
  echo "               The user must set UPF!"
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
  UPF=$4         # The JSON hyperparameter file
else
  usage
  exit 1
fi

if [[ ${UPF:-} == "" ]]
then
  echo "upf workflow.sh: set UPF!"
  exit 1
fi
if ! find_cfg $UPF
then
  crash "Could not find UPF: $UPF"
fi
UPF=$REPLY

source_site env   $SITE
source_site sched $SITE

# Set up PYTHONPATH for model
source $WORKFLOWS_ROOT/common/sh/set-pythonpath.sh

LOG_NAME="workflow.sh"
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
: ${MODEL_RETURN:=val_loss} ${BENCHMARKS_ROOT:=/UNSET}
export MODEL_NAME MODEL_RETURN SH_TIMEOUT IGNORE_ERRORS
export CANDLE_MODEL_TYPE BENCHMARK_TIMEOUT BENCHMARKS_ROOT

if [[ ${UPF_DFLTS:-} != "" ]]
then
  UPF_DFLTS_FLAG=" -d=$UPF_DFLTS"
  cp -v $UPF_DFLTS $TURBINE_OUTPUT
fi

if [[ ${RESTART:-} != "" ]]
then
  RESTART_FROM=$TURBINE_OUTPUT/../$RESTART
  RESTART_FROM=$( realpath $RESTART_FROM )
  assert-exists -d $RESTART_FROM

  log "restarting from: $RESTART_FROM"
  echo $RESTART_FROM > $TURBINE_OUTPUT/restart.txt
  for DIR in markers run
  do
    if [[ -d $RESTART_FROM/$DIR ]]
    then
      LS=( $RESTART_FROM/$DIR/* )
      log "restart: $DIR: ${#LS[@]}"
      cp -r $RESTART_FROM/$DIR $TURBINE_OUTPUT
    fi
  done
fi

CMD_LINE_ARGS=( -expid=$EXPID
                -benchmark_timeout=$BENCHMARK_TIMEOUT
                -f=$UPF
                ${UPF_DFLTS_FLAG:-}
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

cp -v $UPF $TURBINE_OUTPUT

TURBINE_STDOUT="$TURBINE_OUTPUT/out/out-@r.txt"
mkdir -pv $TURBINE_OUTPUT/out

if [[ ${CANDLE_DATA_DIR:-} == "" ]]
then
  abort "upf/workflow.sh: Set CANDLE_DATA_DIR!"
fi

export CANDLE_IMAGE=${CANDLE_IMAGE:-}

ENVS=(
  -e BENCHMARKS_ROOT
  -e EMEWS_PROJECT_ROOT
  -e MODEL_SH
  -e FI_MR_CACHE_MAX_COUNT=0
  -e SITE
  -e BENCHMARK_TIMEOUT
  -e MODEL_NAME=${MODEL_NAME:-MODEL_NULL}
  -e OBJ_RETURN
  -e MODEL_PYTHON_SCRIPT=${MODEL_PYTHON_SCRIPT:-}
  -e TURBINE_MPI_THREAD=${TURBINE_MPI_THREAD:-1}
  $( python_envs )
  -e TURBINE_STDOUT=$TURBINE_STDOUT
  -e "TURBINE_LEADER_HOOK_STARTUP=${TURBINE_LEADER_HOOK_STARTUP:-}"
  -e CANDLE_MODEL_TYPE
  -e CANDLE_IMAGE
  # level 20 == INFO
  -e IMPROVE_LOG_LEVEL=${IMPROVE_LOG_LEVEL:-}
  -e ADLB_DEBUG_RANKS
  -e ADLB_DEBUG_HOSTMAP
  -e DATA_SOURCE

  # Can provide this to debug Python settings:
  #        -e PYTHONVERBOSE=1
  # Can provide this if needed for debugging crashes:
  #        -e PYTHONUNBUFFERED=1
  # Can provide this if needed to reset PATH:
  #        -e PATH=$PATH
)

which swift-t

swift-t -u -n $PROCS \
        -o $THIS/workflow.tic \
        ${MACHINE:-} \
        -p -l \
        -I $WORKFLOWS_ROOT/common/swift \
        -i model_$CANDLE_MODEL_IMPL \
        "${ENVS[@]}" \
        $EMEWS_PROJECT_ROOT/swift/workflow.swift ${CMD_LINE_ARGS[@]}
