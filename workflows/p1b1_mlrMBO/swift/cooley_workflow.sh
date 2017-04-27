#! /usr/bin/env bash

set -eu

if [ "$#" -ne 1 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} EXPERIMENT_ID (e.g. ${script_name} experiment_1)"
  exit 1
fi

# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
export TURBINE_LOG=0 TURBINE_DEBUG=0 ADLB_DEBUG=0
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
# source some utility functions used by EMEWS in this script
source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh"

export EXPID=$1
export TURBINE_OUTPUT=$EMEWS_PROJECT_ROOT/experiments/$EXPID
check_directory_exists

# TODO edit the number of processes as required.
export PROCS=4

# TODO edit QUEUE, WALLTIME, PPN, AND TURNBINE_JOBNAME
# as required. Note that QUEUE, WALLTIME, PPN, AND TURNBINE_JOBNAME will
# be ignored if MACHINE flag (see below) is not set
export QUEUE=default
export WALLTIME=00:45:00
export PPN=2
export TURBINE_JOBNAME="${EXPID}_job"
export PROJECT=Candle_ECP

# if R cannot be found, then these will need to be
# uncommented and set correctly.
# export R_HOME=/path/to/R
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$R_HOME/lib
# export PYTHONHOME=

P1B1_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot1/P1B1
if ! [[ -d $P1B1_DIR ]]
then
  echo "Could not find P1B1 at: $P1B1_DIR"
  exit 1
fi


# PYTHONPATH
PP=
PP+=/soft/analytics/conda/env/Candle_ML/lib/python2.7/site-packages:
PP+=/soft/analytics/conda/env/Candle_ML/lib/python2.7:
PP+=$P1B1_DIR:
PP+=$EMEWS_PROJECT_ROOT/python

# PYTHONHOME
PH=/soft/analytics/conda/env/Candle_ML

# we have to set PYTHONHOME for Keras but we cannot let qsub see this
# variable (or it will fail), so we hide it as PH, and send it to Swift
# via swift-t -e.

# Resident task workers and ranks
# TURBINE_RESIDENT_WORK_WORKERS=1
# RESIDENT_WORK_RANKS=$(( PROCS - 2 ))


# EQ/Py location
EQPY=$EMEWS_PROJECT_ROOT/ext/EQ-Py
# EQ/R location
EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R

# how many to evaluate concurrently
MAX_CONCURRENT_EVALUATIONS=5
# number of iterations of MAX_CONCURRENT_EVALUATIONS
# there will be an addtional 0th iteration that creates the
# initial model.
ITERATIONS=5
PARAM_SET_FILE="$EMEWS_PROJECT_ROOT/data/parameter_set.R"
DATA_DIRECTORY="$EMEWS_PROJECT_ROOT/data"

# TODO edit command line arguments, e.g. -nv etc., as appropriate
# for your EQ/Py based run. $* will pass all of this script's
# command line arguments to the swift script
CMD_LINE_ARGS="$* -pp=$MAX_CONCURRENT_EVALUATIONS -it=$ITERATIONS "
CMD_LINE_ARGS+="-param_set_file=$PARAM_SET_FILE "
CMD_LINE_ARGS+="-data_directory=$DATA_DIRECTORY "

export MODE=cluster

ENVS="-e PYTHONHOME=$PH -e PYTHONPATH=$PP -e TURBINE_RESIDENT_WORK_WORKERS=1 -e RESIDENT_WORK_RANKS=$(( PROCS - 2 )) -e EMEWS_PROJECT_ROOT=$EMEWS_PROJECT_ROOT -e TURBINE_OUTPUT=$TURBINE_OUTPUT"

# set machine to your schedule type (e.g. pbs, slurm, cobalt etc.),
# or empty for an immediate non-queued unscheduled run
MACHINE="cobalt"

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
SWIFT_FILE=workflow.swift
swift-t -n $PROCS $MACHINE -p $ENVS -I $EQR -r $EQR \
  $EMEWS_PROJECT_ROOT/swift/$SWIFT_FILE $CMD_LINE_ARGS
