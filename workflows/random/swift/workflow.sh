#!/bin/bash
set -eu

# RANDOM WORKFLOW SH

usage()
{
  echo "random/workflow.sh: usage: workflow.sh SITE EXPID"
}

if (( ${#} != 2 ))
then
  usage
  exit 1
fi

# Self-configure
THIS=$(               cd $( dirname $0 )        && /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/..               && /bin/pwd )
WORKFLOWS_ROOT=$(     cd $EMEWS_PROJECT_ROOT/.. && /bin/pwd )
SUPERVISOR_HOME=$(    cd $WORKFLOWS_ROOT/..     && /bin/pwd )
export EMEWS_PROJECT_ROOT
source $WORKFLOWS_ROOT/common/sh/utils.sh

SCRIPT_NAME=$( basename $0)

if ! {
  get_site    $1 # Sets SITE
  get_expid   $2 # Sets EXPID
 }
then
  usage
  exit 1
fi

source_site env   $SITE
source_site sched $SITE

# Sets the scheduler job name for convenience
export TURBINE_JOBNAME=${EXPID}

# settings.json file has all the parameter ranges to be tested
CMD_LINE_ARGS=( -param_set_file=$EMEWS_PROJECT_ROOT/data/settings.json
                -model_name=$MODEL_NAME
                -exp_id=$EXPID
                -benchmark_timeout=${BENCHMARK_TIMEOUT:-0}
                -site=$SITE
              )

# Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=($CMD_LINE_ARGS "VAR_1" "VAR_2")
USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

if [[ ${CANDLE_MODEL_TYPE:-} == "SINGULARITY" ]]
then
  CANDLE_MODEL_IMPL="container"
  BENCHMARKS_ROOT=""
fi
SWIFT_LIBS_DIR=${SWIFT_LIBS_DIR:-$WORKFLOWS_ROOT/common/swift}
SWIFT_MODULE=${SWIFT_MODULE:-model_$CANDLE_MODEL_IMPL}

# echo's anything following this to stdout

swift-t -n $PROCS \
        ${MACHINE:-} \
        -I $WORKFLOWS_ROOT/common/swift \
        -I $SWIFT_LIBS_DIR \
        -i $SWIFT_MODULE \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e EMEWS_PROJECT_ROOT \
        $( python_envs ) \
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        $EMEWS_PROJECT_ROOT/swift/workflow.swift ${CMD_LINE_ARGS[@]}
