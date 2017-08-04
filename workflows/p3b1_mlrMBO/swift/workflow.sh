#! /usr/bin/env bash
set -eu

# WORKFLOW
# Main entry point for P3B1 mlrMBO workflow
# See README.md for more information

# Autodetect the workflow directories
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
BENCHMARKS_ROOT=$( cd $EMEWS_PROJECT_ROOT/../../../Benchmarks ; /bin/pwd)
BENCHMARK_DIR=$BENCHMARKS_ROOT/Pilot3/P3B1
SCRIPT_NAME=$(basename $0)

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh
source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh"

# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1

usage()
{
  echo "P3B1: usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM"
}

if (( ${#} != 4 ))
then
  usage
  exit 1
fi

echo $*

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

export TURBINE_JOBNAME="JOB:${EXPID}"

source_site modules $SITE
source_site langs   $SITE
source_site sched   $SITE

# The Swift Implementation type: "app" or "py"
# Selects the *.swift files to include
# If "app", use app functions
# If "py", use in-memory Python functions
SWIFT_IMPL="py"

SCRIPTS_TITAN=""
if [[ ${SITE} == "titan" ]]
then
  SCRIPTS_TITAN=(
    -script_file=$EMEWS_PROJECT_ROOT/scripts/titan_run_model.sh
    -log_script=$WORKFLOWS_ROOT/common/sh/titan_run_logger.sh
  )
  # TODO:
  SWIFT_IMPL="app"
fi

CMD_LINE_ARGS=( $* # Extra user args
                -exp_id=$EXPID
                -pp=$PROPOSE_POINTS
                -mi=$MAX_ITERATIONS
                -mb=$MAX_BUDGET
                -ds=$DESIGN_SIZE
                -param_set_file=$PARAM_SET_FILE
                ${SCRIPTS_TITAN[@]}
              )

# Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=("VAR_1" "VAR_2")
USER_VARS=($CMD_LINE_ARGS)
# log variables and script to to TURBINE_OUTPUT directory
log_script $EMEWS_PROJECT_ROOT/swift/$SCRIPT_NAME

set -x
WORKFLOW_SWIFT=workflow.swift
swift-t -p $MACHINE \
        -I $EMEWS_PROJECT_ROOT/swift \
        -i log_$SWIFT_IMPL \
        -i obj_$SWIFT_IMPL \
        -n $PROCS \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -I $EQR -r $EQR \
        -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
        -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
        -e EMEWS_PROJECT_ROOT=$EMEWS_PROJECT_ROOT \
        -e PYTHONPATH=$PYTHONPATH \
        -e PYTHONHOME=$PYTHONHOME \
        -e TURBINE_LOG=$TURBINE_LOG \
        -e TURBINE_DEBUG=$TURBINE_DEBUG\
        -e ADLB_DEBUG=$ADLB_DEBUG \
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        $EMEWS_PROJECT_ROOT/swift/$WORKFLOW_SWIFT ${CMD_LINE_ARGS[@]}
