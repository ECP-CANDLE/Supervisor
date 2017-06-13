#! /usr/bin/env bash
set -eu

# CORI WORKFLOW
# Main entry point for P1B3 mlrMBO workflow

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )

# USER SETTINGS START

# See README.md for more information

# The directory in the Benchmarks repo containing P1B3
BENCHMARK_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot1/nt3

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
# The default of 4 gives you 2 workers, i.e., 2 concurrent Keras runs
export PROCS=${PROCS:-10}

# MPI processes per node
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-1}


export QUEUE="default"
export WALLTIME=${WALLTIME:-02:00:00}

# mlrMBO settings
# How many to runs evaluate per iteration


MAX_BUDGET=${MAX_BUDGET:-110}
# Total iterations
MAX_ITERATIONS=${MAX_ITERATIONS:-4}
DESIGN_SIZE=${DESIGN_SIZE:-8}
PROPOSE_POINTS=${PROPOSE_POINTS:-8}
PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/parameter_set3.R}
MODEL_NAME="nt3"
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

# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
#export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1

export EXPID=$1
export TURBINE_OUTPUT=$EMEWS_PROJECT_ROOT/experiments/$EXPID
check_directory_exists

export TURBINE_JOBNAME="${EXPID}_job"

# if R cannot be found, then these will need to be
# uncommented and set correctly.
# export R_HOME=/path/to/R
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$R_HOME/lib
# export PYTHONHOME=



TCL=/gpfs/mira-home/wozniak/Public/sfw/theta/tcl-8.6.1
export R=/home/wozniak/mira-home/Public/sfw/theta/R-3.4.0/lib64/R
export PY=/gpfs/mira-home/wozniak/Public/sfw/theta/Python-2.7.12
export LD_LIBRARY_PATH=$PY/lib:$R/lib:$LD_LIBRARY_PATH
COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH=$EMEWS_PROJECT_ROOT/python:$BENCHMARK_DIR:$COMMON_DIR
PYTHONHOME=/gpfs/mira-home/wozniak/Public/sfw/theta/Python-2.7.12

export PATH=/gpfs/mira-home/wozniak/Public/sfw/theta/swift-t-pyr/stc/bin:$TCL/bin:$PATH
#$PYTHONHOME/bin:$TCL/bin:$PATH

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# EQ/R location
EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R

CMD_LINE_ARGS="$* -pp=$PROPOSE_POINTS -mi=$MAX_ITERATIONS -mb=$MAX_BUDGET -ds=$DESIGN_SIZE "
CMD_LINE_ARGS+="-param_set_file=$PARAM_SET_FILE -script_file=$EMEWS_PROJECT_ROOT/scripts/theta_run_model.sh "
CMD_LINE_ARGS+="-model_name=$MODEL_NAME"

# set machine to your scheduler type (e.g. pbs, slurm, cobalt etc.),
# or empty for an immediate non-queued unscheduled run
MACHINE="theta"

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
WORKFLOW_SWIFT=theta_workflow.swift
swift-t -n $PROCS $MACHINE -p -I $EQR -r $EQR \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
    -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
    -e EMEWS_PROJECT_ROOT=$EMEWS_PROJECT_ROOT \
    -e PYTHONPATH=$PYTHONPATH \
    -e PYTHONHOME=$PYTHONHOME \
    -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        $EMEWS_PROJECT_ROOT/swift/$WORKFLOW_SWIFT $CMD_LINE_ARGS
