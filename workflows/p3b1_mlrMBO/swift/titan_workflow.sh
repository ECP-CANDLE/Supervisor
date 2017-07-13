#! /usr/bin/env bash
set -eu

# TITAN WORKFLOW
# Main entry point for P1B3 mlrMBO workflow

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )

# USER SETTINGS START

# See README.md for more information

BENCHMARK_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot3/P3B1

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
export PROCS=${PROCS:-32}

# MPI processes per node
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-1}
export QUEUE=${QUEUE:-default}
export WALLTIME=${WALLTIME:-05:00:00}

# Benchmark run timeout: benchmark run will timeouT
# after the specified number of seconds. -1 is no timeout.
BENCHMARK_TIMEOUT=${BENCHMARK_TIMEOUT:--1}

# mlrMBO settings
MAX_BUDGET=${MAX_BUDGET:-110}
# Total iterations
MAX_ITERATIONS=${MAX_ITERATIONS:-4}
DESIGN_SIZE=${DESIGN_SIZE:-30}
PROPOSE_POINTS=${PROPOSE_POINTS:-30}
PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/parameter_set3.R}
MODEL_NAME="p3b1"
# pbalabra:
# PARAM_SET_FILE="$EMEWS_PROJECT_ROOT/data/parameter_set1.R"

# USER SETTINGS END


# Source some utility functions used by EMEWS in this script
source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh"

script_name=$(basename $0)

if [ "$#" -ne 1 ]; then
  echo "Usage: ${script_name} EXPERIMENT_ID (e.g. ${script_name} experiment_1)"
  exit 1
fi

# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1

export EXPID=$1
export TURBINE_OUTPUT_ROOT=${TURBINE_OUTPUT_ROOT:-$EMEWS_PROJECT_ROOT/experiments}
export TURBINE_OUTPUT=$TURBINE_OUTPUT_ROOT/$EXPID
check_directory_exists

export TURBINE_JOBNAME="${EXPID}_job"

# if R cannot be found, then these will need to be
# uncommented and set correctly.
# export R_HOME=/path/to/R
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$R_HOME/lib
# export PYTHONHOME=

TCL=/sw/xk6/tcl_tk/8.5.8/sles11.1_gnu4.5.3
export R=/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3x/lib64/R
export PY=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3
export LD_LIBRARY_PATH=$PY/lib:$R/lib:$LD_LIBRARY_PATH
COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH=$EMEWS_PROJECT_ROOT/python:$BENCHMARK_DIR:$COMMON_DIR
PYTHONHOME=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3

export PATH=/lustre/atlas2/csc249/proj-shared/sfw/swift-t/stc/bin/:$TCL/bin:$PATH
#$PYTHONHOME/bin:$TCL/bin:$PATH

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# EQ/R location
EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R

CMD_LINE_ARGS="$* -pp=$PROPOSE_POINTS -mi=$MAX_ITERATIONS -mb=$MAX_BUDGET -ds=$DESIGN_SIZE "
CMD_LINE_ARGS+="-param_set_file=$PARAM_SET_FILE -script_file=$EMEWS_PROJECT_ROOT/scripts/titan_run_model.sh "
CMD_LINE_ARGS+="-exp_id=$EXPID -log_script=$EMEWS_PROJECT_ROOT/../common/sh/titan_run_logger.sh -benchmark_timeout=$BENCHMARK_TIMEOUT"

# set machine to your scheduler type (e.g. pbs, slurm, cobalt etc.),
# or empty for an immediate non-queued unscheduled run
MACHINE="cray"

if [ -n "$MACHINE" ]; then
  MACHINE="-m $MACHINE"
fi

# Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=("VAR_1" "VAR_2")
USER_VARS=($CMD_LINE_ARGS)
# log variables and script to to TURBINE_OUTPUT directory
log_script $EMEWS_PROJECT_ROOT/swift/$script_name

LD_LIBRARY_PATH=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/lib:/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/cuda/lib64:/opt/gcc/4.9.3/snos/lib64:/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3x/lib64/R/lib
SWIFT=/lustre/atlas2/csc249/proj-shared/sfw/swift-t/stc/bin/swift-t
export PROJECT=CSC249ADOA01
export TITAN=true

# echo's anything following this to standard out
set -x
WORKFLOW_SWIFT=ai_workflow3.swift
$SWIFT -m cray -n $PROCS\
       -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
       -p -I $EQR -r $EQR \
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
