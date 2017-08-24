#! /usr/bin/env bash
set -eu

# NT3 WORKFLOW
# Main entry point for NT3 mlrMBO workflow
# See README.md for more information

echo "WORKFLOW: NT3"

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
BENCHMARKS_ROOT=$( cd $EMEWS_PROJECT_ROOT/../../../Benchmarks ; /bin/pwd)
BENCHMARK_DIR=$BENCHMARKS_ROOT/Pilot3/P3B1
SCRIPT_NAME=$(basename $0)

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh
source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh"

# Set TURBINE_LOG=1 for Swift logging, TURBINE_LOG=0 to disable
export TURBINE_LOG=0

usage()
{
  echo "NT3: usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM"
}

if (( ${#} != 4 ))
then
  usage
  exit 1
fi

if ! {
  get_site    $1 # Sets SITE
  get_expid   $2 # Sets EXPID and TURBINE_OUTPUT
  get_cfg_sys $3
  get_cfg_prm $4
}
then
  usage
  exit 1
fi

source_site modules $SITE
source_site langs   $SITE
source_site sched   $SITE

STR_RUN_MODEL=$SITE"_run_model.sh"
STR_RUN_LOGGER=$SITE"_run_logger.sh"

export TURBINE_JOBNAME="JOB:${EXPID}"

CMD_LINE_ARGS=( -pp=$PROPOSE_POINTS
                -mi=$MAX_ITERATIONS
                -mb=$MAX_BUDGET
                -ds=$DESIGN_SIZE
                -param_set_file=$PARAM_SET_FILE
                -script_file=$EMEWS_PROJECT_ROOT/scripts/$STR_RUN_MODEL
                -model_name=$MODEL_NAME
                -exp_id=$EXPID
                -log_script=$EMEWS_PROJECT_ROOT/../common/sh/$STR_RUN_LOGGER
                -benchmark_timeout=$BENCHMARK_TIMEOUT
              )

# Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=($CMD_LINE_ARGS "VAR_1" "VAR_2")
USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

WORKFLOW_SWIFT=workflow.swift
swift-t -n $PROCS \
        $MACHINE  \
        -p -I $EQR -r $EQR \
        -I $EMEWS_PROJECT_ROOT/swift \
        -i obj_$SWIFT_IMPL \
        -i log_$SWIFT_IMPL \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
        -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
        -e EMEWS_PROJECT_ROOT=$EMEWS_PROJECT_ROOT \
        -e PYTHONPATH=$PYTHONPATH \
        -e PYTHONHOME=$PYTHONHOME \
        -e TURBINE_LOG=$TURBINE_LOG \
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        $EMEWS_PROJECT_ROOT/swift/$WORKFLOW_SWIFT ${CMD_LINE_ARGS[@]}
