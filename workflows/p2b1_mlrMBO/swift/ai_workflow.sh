#! /usr/bin/env bash

#! /usr/bin/env bash

set -eu

# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
# export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )

# USER SETTINGS START

# See README.md for more information

# The directory in the Benchmarks repo containing P2B1
BENCHMARK_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot2/P2B1

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
# The default of 4 gives you 2 workers, i.e., 2 concurrent Keras runs
export PROCS=${PROCS:-4}

# MPI processes per node
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-1}

# See http://www.nersc.gov/users/computational-systems/cori/running-jobs/queues-and-policies/
export QUEUE=${QUEUE:-debug}
export WALLTIME=${WALLTIME:-00:30:00}

# Benchmark run timeout: benchmark run will timeouT
# after the specified number of seconds. -1 is no timeout.
BENCHMARK_TIMEOUT=${BENCHMARK_TIMEOUT:--1}

# set machine to your scheduler type (e.g. pbs, slurm, cobalt etc.),
# or empty for an immediate non-queued unscheduled run
MACHINE=""

# mlrMBO settings
MAX_BUDGET=${MAX_BUDGET:-110}
# Total iterations
MAX_ITERATIONS=${MAX_ITERATIONS:-4}
DESIGN_SIZE=${DESIGN_SIZE:-8}
PROPOSE_POINTS=${PROPOSE_POINTS:-8}
PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/parameter_set3.R}

SCRIPT_FILE=$EMEWS_PROJECT_ROOT/scripts/run_model.sh
LOG_SCRIPT_FILE=$EMEWS_PROJECT_ROOT/../common/sh/run_logger.sh
# USER SETTINGS END

# source some utility functions used by EMEWS in this script
source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh"

if [ "$#" -ne 1 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} EXPERIMENT_ID (e.g. ${script_name} experiment_1)"
  exit 1
fi

# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
#export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1

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

COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
export PYTHONPATH=$EMEWS_PROJECT_ROOT/python:$EMEWS_PROJECT_ROOT/ext/EQ-Py:$BENCHMARK_DIR:$COMMON_DIR

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# EQ/R location
EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R

CMD_LINE_ARGS="$* -pp=$PROPOSE_POINTS -mi=$MAX_ITERATIONS -mb=$MAX_BUDGET -ds=$DESIGN_SIZE "
CMD_LINE_ARGS+="-param_set_file=$PARAM_SET_FILE  -script_file=$SCRIPT_FILE "
CMD_LINE_ARGS+="-exp_id=$EXPID -log_script=$LOG_SCRIPT_FILE "
CMD_LINE_ARGS+="-benchmark_timeout=$BENCHMARK_TIMEOUT"

if [ -n "$MACHINE" ]; then
  MACHINE="-m $MACHINE"
fi

# Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=("VAR_1" "VAR_2")
USER_VARS=($CMD_LINE_ARGS)
# log variables and script to to TURBINE_OUTPUT directory
log_script

# echo's anything following this to standard out
set -x
WORKFLOW_SWIFT=ai_workflow3.swift
swift-t -n $PROCS $MACHINE -p -I $EQR -r $EQR \
        $EMEWS_PROJECT_ROOT/swift/$WORKFLOW_SWIFT $CMD_LINE_ARGS
