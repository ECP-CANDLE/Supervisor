#! /usr/bin/env bash
set -eu

# TITAN WORKFLOW
# Main entry point for P1B3 mlrMBO workflow

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )

# USER SETTINGS START

# See README.md for more information

# The directory in the Benchmarks repo containing P1B3
P1B3_DIR=$( cd $EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot1/P1B3 ; /bin/pwd )

echo $P1B3_DIR ; ls $P1B3_DIR

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
# The default of 4 gives you 2 workers, i.e., 2 concurrent Keras runs
export PROCS=${PROCS:-4}

# MPI processes per node
export PPN=${PPN:-4}

export QUEUE=${QUEUE:-debug}
export WALLTIME=${WALLTIME:-00:02:00}

# mlrMBO settings
# How many to runs evaluate per iteration
MAX_CONCURRENT_EVALUATIONS=${MAX_CONCURRENT_EVALUATIONS:-2}
# Total iterations
MAX_ITERATIONS=${MAX_ITERATIONS:-3}
PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/parameter_set.R}
# pbalabra: 
# PARAM_SET_FILE="$EMEWS_PROJECT_ROOT/data/parameter_set1.R"

# USER SETTINGS END

# Source some utility functions used by EMEWS in this script
source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh"

if [ "$#" -ne 1 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} EXPERIMENT_ID (e.g. ${script_name} experiment_1)"
  exit 1
fi

# Uncomment to turn on Swift/T logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
#export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1

export EXPID=$1
export TURBINE_OUTPUT=$HOME/FS/experiments/$EXPID
check_directory_exists

export TURBINE_JOBNAME="${EXPID}_job"

# if R cannot be found, then these will need to be
# uncommented and set correctly.
# export R_HOME=/path/to/R
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$R_HOME/lib
# export PYTHONHOME=

#P1B3_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot1/P1B3

export LD_LIBRARY_PATH=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/lib:/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/cuda/lib64

export PYTHONPATH=$EMEWS_PROJECT_ROOT/python:$P1B3_DIR:$PYTHONPATH

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# EQ/R location
EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R

CMD_LINE_ARGS="$* -pp=$MAX_CONCURRENT_EVALUATIONS -it=$MAX_ITERATIONS "
CMD_LINE_ARGS+="-param_set_file=$PARAM_SET_FILE "

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
log_script

R_LIB=/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3x/lib64/R/lib 
GCC_LIB=/opt/gcc/4.9.3/snos/lib64

set -x
WORKFLOW_SWIFT=workflow.swift
swift-t -n $PROCS $MACHINE -p -I $EQR -r $EQR \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$R_LIB:$GCC_LIB \
        -e EMEWS_PROJECT_ROOT \
        -e TURBINE_RESIDENT_WORK_WORKERS \
        -e RESIDENT_WORK_RANKS \
        -e PYTHONPATH \
        $EMEWS_PROJECT_ROOT/swift/$WORKFLOW_SWIFT $CMD_LINE_ARGS
