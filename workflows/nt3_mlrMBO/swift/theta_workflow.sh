#! /usr/bin/env bash
set -eu

# WORKFLOW
# Main entry point for P3B1 mlrMBO workflow
# See README.md for more information

# Autodetect this workflow directory
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
  echo "NT3: usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM"
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

source_site modules $SITE
source_site langs   $SITE
source_site sched   $SITE

export TURBINE_JOBNAME="JOB:${EXPID}"

# TCL=/home/wozniak/Public/sfw/theta/tcl-8.6.1
# export R=/home/wozniak/Public/sfw/theta/R-3.4.0/lib64/R
# export PY=/home/wozniak/Public/sfw/theta/Python-2.7.12
# export LD_LIBRARY_PATH=$PY/lib:$R/lib:$LD_LIBRARY_PATH
# COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
# PYTHONPATH=$EMEWS_PROJECT_ROOT/python:$BENCHMARK_DIR:$COMMON_DIR
# PYTHONHOME=/home/wozniak/Public/sfw/theta/Python-2.7.12

# # export PATH=/home/wozniak/Public/sfw/theta/swift-t-pyr/stc/bin:$PATH
# export PATH=/projects/Candle_ECP/swift/2017-08-11/stc/bin:$PATH
# PATH=$TCL/bin:$PATH
# #$PYTHONHOME/bin:$TCL/bin:$PATH

# # Resident task workers and ranks
# export TURBINE_RESIDENT_WORK_WORKERS=1
# export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# # EQ/R location
# EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R

CMD_LINE_ARGS=( $* # Extra user args
                -pp=$PROPOSE_POINTS
                -mi=$MAX_ITERATIONS
                -mb=$MAX_BUDGET
                -ds=$DESIGN_SIZE
                -param_set_file=$PARAM_SET_FILE
                -script_file=$EMEWS_PROJECT_ROOT/scripts/theta_run_model.sh
                -model_name=$MODEL_NAME
                -exp_id=$EXPID
                -log_script=$EMEWS_PROJECT_ROOT/../common/sh/theta_run_logger.sh
                -benchmark_timeout=$BENCHMARK_TIMEOUT
              )

# Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=($CMD_LINE_ARGS "VAR_1" "VAR_2")
USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

# echo's anything following this to standard out
set -x
WORKFLOW_SWIFT=ai_workflow3.swift
swift-t -n $PROCS $MACHINE -p -I $EQR -r $EQR   \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
        -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
        -e EMEWS_PROJECT_ROOT=$EMEWS_PROJECT_ROOT \
        -e PYTHONPATH=$PYTHONPATH \
        -e PYTHONHOME=$PYTHONHOME \
        -e TURBINE_LOG=$TURBINE_LOG \
        -e TURBINE_DEBUG=$TURBINE_DEBUG\
        -e ADLB_DEBUG=$ADLB_DEBUG \
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        $EMEWS_PROJECT_ROOT/swift/$WORKFLOW_SWIFT $CMD_LINE_ARGS
