#! /usr/bin/env bash
set -eu

# P3B1 WORKFLOW
# Main entry point for P3B1 mlrMBO workflow
# See README.md for more information

echo "WORKFLOW: P3B1"

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
export WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
export BENCHMARKS_ROOT=$( cd $EMEWS_PROJECT_ROOT/../../../Benchmarks ; /bin/pwd)
export BENCHMARK_DIR=$BENCHMARKS_ROOT/Pilot3/P3B1
SCRIPT_NAME=$(basename $0)

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh
source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh"

usage()
{
  echo "P3B1: usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM"
}

if (( ${#} != 4 ))
then
  usage
  exit 1
fi

if ! {
  get_site    $1 # Sets SITE
  get_expid   $2 # Sets EXPID
  get_cfg_sys $3
  get_cfg_prm $4
 }
then
  usage
  exit 1
fi

# Set PYTHONPATH for BENCHMARK related stuff
PYTHONPATH+=:$BENCHMARK_DIR:$BENCHMARKS_ROOT/common

source_site modules $SITE
source_site langs   $SITE
source_site sched   $SITE

if [[ ${EQR:-} == "" ]]
then
  abort "The site '$SITE' did not set the location of EQ/R: this will not work!"
fi

export TURBINE_JOBNAME="JOB:${EXPID}"

# START ITERATION HACK
# Uncomment the non-empty START and set the number to use a start iteration
START=""
# START=-start=1

CMD_LINE_ARGS=( -mb=$MAX_BUDGET
                -ds=$DESIGN_SIZE
                -pp=$PROPOSE_POINTS
                $START
                -it=$MAX_ITERATIONS
                -param_set_file=$PARAM_SET_FILE
                -script_file=$EMEWS_PROJECT_ROOT/scripts/run_model.sh
                -model_name=$MODEL_NAME
                -exp_id=$EXPID
                -log_script=$EMEWS_PROJECT_ROOT/../common/sh/run_logger.sh
                -benchmark_timeout=$BENCHMARK_TIMEOUT
                -site=$SITE
              )

# Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=($CMD_LINE_ARGS "VAR_1" "VAR_2")
USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

# echo's anything following this to standard out
swift-t -n $PROCS \
        ${MACHINE:-} \
        -p -I $EQR -r $EQR \
        -I $EMEWS_PROJECT_ROOT/swift \
        -i obj_$SWIFT_IMPL \
        -i log_$SWIFT_IMPL \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
        -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
        -e BENCHMARKS_ROOT \
        -e EMEWS_PROJECT_ROOT \
        $( python_envs ) \
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        $EMEWS_PROJECT_ROOT/swift/workflow.swift ${CMD_LINE_ARGS[@]}
