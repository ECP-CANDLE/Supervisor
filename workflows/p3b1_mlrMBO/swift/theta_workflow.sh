#! /usr/bin/env bash
set -eu

# THETA WORKFLOW
# Main entry point for P1B3 mlrMBO workflow

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )

# USER SETTINGS START

# See README.md for more information

# The directory in the Benchmarks repo containing P1B3
BENCHMARK_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot3/P3B1
# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
export PROCS=${PROCS:-32}

# MPI processes per node
# (Theta has 64 cores per node, 192GB per node)
export PPN=${PPN:-1}

export QUEUE=${QUEUE:-default}
export WALLTIME=${WALLTIME:-02:00:00}

# Benchmark run timeout: benchmark run will timeouT
# after the specified number of seconds. -1 is no timeout.
BENCHMARK_TIMEOUT=${BENCHMARK_TIMEOUT:--1}

# mlrMBO settings
# How many to runs evaluate per iteration

MAX_BUDGET=${MAX_BUDGET:-110}
# Total iterations
MAX_ITERATIONS=${MAX_ITERATIONS:-4}
DESIGN_SIZE=${DESIGN_SIZE:-30}
PROPOSE_POINTS=${PROPOSE_POINTS:-30}
PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/parameter_set3.R}

# pbalabra:
# PARAM_SET_FILE="$EMEWS_PROJECT_ROOT/data/parameter_set1.R"

# USER SETTINGS END

# Source some utility functions used by EMEWS in this script
source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh"

WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT ; cd .. ; /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/langs-theta.sh
source $WORKFLOWS_ROOT/common/sh/utils.sh

# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
# export TURBINE_LOG=1 # TURBINE_DEBUG=1 ADLB_DEBUG=1

get_expid $*

export TURBINE_JOBNAME="${EXPID}_job"

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# EQ/R location
EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R

SCRIPT_FILE=$EMEWS_PROJECT_ROOT/scripts/theta_run_model.sh
LOG_SCRIPT=$EMEWS_PROJECT_ROOT/../common/sh/theta_run_logger.sh

CMD_LINE_ARGS=( $*
                -exp_id=$EXPID
                -pp=$PROPOSE_POINTS
                -mi=$MAX_ITERATIONS
                -mb=$MAX_BUDGET
                -ds=$DESIGN_SIZE
                -param_set_file=$PARAM_SET_FILE
                -script_file=$SCRIPT_FILE
                -log_script=$LOG_SCRIPT
                -benchmark_timeout=$BENCHMARK_TIMEOUT

              )

TURBINE_DIR=/home/wozniak/Public/sfw/theta/swift-t-pyr/turbine/lib

# Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=("VAR_1" "VAR_2")
USER_VARS=($CMD_LINE_ARGS)
# log variables and script to to TURBINE_OUTPUT directory
# log_script

# echo's anything following this to standard out
set -x
WORKFLOW_SWIFT=$EMEWS_PROJECT_ROOT/swift/ai_workflow3.swift
swift-t -m theta \
        -n $PROCS \
        -p -I $EQR -r $EQR -r $TURBINE_DIR \
        -t i:$EMEWS_PROJECT_ROOT/swift/init-theta.sh \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e TURBINE_RESIDENT_WORK_WORKERS \
        -e RESIDENT_WORK_RANKS \
        -e EMEWS_PROJECT_ROOT \
        -e PYTHONPATH=$PYTHONPATH \
        -e PYTHONHOME=$PYTHONHOME \
        $WORKFLOW_SWIFT ${CMD_LINE_ARGS[@]}
