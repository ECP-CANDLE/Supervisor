#! /usr/bin/env bash
set -eu

# May need this on Cori: -Wozniak
# module swap PrgEnv-intel PrgEnv-gnu
# module load deeplearning

if [ "$#" -ne 1 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} EXPERIMENT_ID (e.g. ${script_name} experiment_1)"
  exit 1
fi

# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
# export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
# source some utility functions used by EMEWS in this script
source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh"

export EXPID=$1
if [ $EXPID = "-a" ]; then
  export TURBINE_OUTPUT_ROOT=$EMEWS_PROJECT_ROOT/experiments
  export TURBINE_OUTPUT_FORMAT=X%Q
  EXPID=SWIFT
else
  export TURBINE_OUTPUT=$EMEWS_PROJECT_ROOT/experiments/$EXPID
  check_directory_exists
fi

# TODO edit the number of processes as required.
PROCS=4

# TODO edit QUEUE, WALLTIME, PPN, AND TURNBINE_JOBNAME
# as required. Note that QUEUE, WALLTIME, PPN, AND TURNBINE_JOBNAME will
# be ignored if MACHINE flag (see below) is not set
# export QUEUE=batch
export WALLTIME=00:10:00
export PPN=${PPN:-16}
export TURBINE_JOBNAME="${EXPID}_job"

# if R cannot be found, then these will need to be
# uncommented and set correctly.
# export R_HOME=/path/to/R
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$R_HOME/lib
# export PYTHONHOME=/path/to/python

# EQ/Py location
EQPY=$EMEWS_PROJECT_ROOT/ext/EQ-Py

# Reorder PYTHONPATH -Wozniak
PYTHONPATH_USER=${PYTHONPATH:-}
export PYTHONPATH=
PYTHONPATH+=$EMEWS_PROJECT_ROOT/python:
PYTHONPATH+=$EQPY:
PYTHONPATH+=$EMEWS_PROJECT_ROOT/../../python/hyperopt:
PYTHONPATH+=/usr/common/software/python/2.7-anaconda/envs/deeplearning:
PYTHONPATH+=$PYTHONPATH_USER

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

EVALUATIONS=100
PARAM_BATCH_SIZE=10

# TODO edit command line arguments, e.g. -nv etc., as appropriate
# for your EQ/Py based run. $* will pass all of this script's
# command line arguments to the swift script
CMD_LINE_ARGS="$* -seed=1234 -max_evals=$EVALUATIONS -param_batch_size=$PARAM_BATCH_SIZE"

# Uncomment this for the BG/Q:
#export MODE=BGQ QUEUE=default

# set machine to your schedule type (e.g. pbs, slurm, cobalt etc.),
# or empty for an immediate non-queued unscheduled run
MACHINE=${MACHINE:-}

if [ -n "$MACHINE" ]; then
  MACHINE="-m $MACHINE"
fi

# Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=("VAR_1" "VAR_2")
USER_VARS=($CMD_LINE_ARGS)
# log variables and script to to TURBINE_OUTPUT directory
log_script

PYTHONHOME=${PYTHONHOME:-}
PATH=$PYTHONHOME/bin:$PATH

echo Python settings:
echo "executable: $( which python )"
echo PYTHONHOME ${PYTHONHOME:-}
echo PYTHONPATH ${PYTHONPATH:-}

# export TURBINE_LOG=1

# echo's anything following this to standard out
# set -x
SWIFT_FILE=swift_run_eqpy.swift
# SWIFT_FILE=simpler_imports.swift

#         -e PYTHONHOME=$PYTHONHOME

swift-t -O0 -l -n $PROCS $MACHINE -p -I $EQPY -r $EQPY \
        -e PATH=$PATH \
        -e PYTHONPATH=$PYTHONPATH \
        $EMEWS_PROJECT_ROOT/swift/$SWIFT_FILE $CMD_LINE_ARGS

