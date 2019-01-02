#! /usr/bin/env bash

set -eu

if [ "$#" -ne 1 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} EXPERIMENT_ID  (e.g. ${script_name} experiment_1)"
  exit 1
fi

SWIFT_T=/home/nick/sfw/swift-t-4c8f0afd
PATH=$SWIFT_T/stc/bin:$PATH


# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
# export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
# source some utility functions used by EMEWS in this script
source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh"

export EXPID=$1
export TURBINE_OUTPUT=$EMEWS_PROJECT_ROOT/experiments/$EXPID
check_directory_exists

# TODO edit the number of processes as required.
# 1040
export PROCS=8

# TODO edit QUEUE, WALLTIME, PPN, AND TURNBINE_JOBNAME
# as required. Note that QUEUE, WALLTIME, PPN, AND TURNBINE_JOBNAME will
# be ignored if the MACHINE variable (see below) is not set.
export QUEUE=batch
export WALLTIME=200:00:00
export PPN=8
export TURBINE_JOBNAME="${EXPID}_job"

# EQ/Py location
EQPy=$EMEWS_PROJECT_ROOT/ext/EQ-Py

export PYTHONPATH=$EMEWS_PROJECT_ROOT/python:$EQPy

CMD_LINE_ARGS="$*"

# if R cannot be found, then these will need to be
# uncommented and set correctly.
# export R_HOME=/path/to/R
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$R_HOME/lib
# if python packages can't be found, then uncommited and set this
# export PYTHONPATH=/path/to/python/packages

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=4
START=$(( PROCS - TURBINE_RESIDENT_WORK_WORKERS - 1 ))
END=$(( START + TURBINE_RESIDENT_WORK_WORKERS - 1 ))
export RESIDENT_WORK_RANKS=$(seq -s , $START 1 $END )
#echo $RESIDENT_WORK_RANKS
#$(( PROCS - 2 ))



# set machine to your schedule type (e.g. pbs, slurm, cobalt etc.),
# or empty for an immediate non-queued unscheduled run
MACHINE=""

if [ -n "$MACHINE" ]; then
  MACHINE="-m $MACHINE"
fi

MODEL_DIR=$EMEWS_PROJECT_ROOT/model

export TURBINE_MPI_THREAD=1
export MPICH_MAX_THREAD_SAFETY=multiple


# Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=("VAR_1" "VAR_2")
USER_VARS=()
# log variables and script to to TURBINE_OUTPUT directory
log_script

# echo's anything following this standard out
set -x

swift-t -n $PROCS $MACHINE -p  -r$EQPy -I $EQPy \
  -e MPICH_MAX_THREAD_SAFETY=$MPICH_MAX_THREAD_SAFETY \
  -e PYTHONPATH=$PYTHONPATH \
  $EMEWS_PROJECT_ROOT/swift/workflow.swift 