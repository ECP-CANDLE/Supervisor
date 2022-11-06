#!/bin/bash
#
# Usage: ./run
#

if [ "$#" -ne 1 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} EXPERIMENT_ID (e.g. ${script_name} experiment_1)"
  exit 1
fi

#### set this variable to your P1B1 benchmark directory (frameworks branch)
P1B1_DIR=../../../../Benchmarks/Pilot1/P1B1
###

THIS=$( cd $( dirname $0 ); /bin/pwd )
export EMEWS_PROJECT_ROOT=$THIS

PROJECT_ROOT=$EMEWS_PROJECT_ROOT/..


export EXPID=$1
export TURBINE_OUTPUT=$EMEWS_PROJECT_ROOT/../experiments/$EXPID


# TODO edit QUEUE, WALLTIME, PPN, AND TURNBINE_JOBNAME
# as required. Note that QUEUE, WALLTIME, PPN, AND TURNBINE_JOBNAME will
# be ignored if MACHINE flag (see below) is not set
export QUEUE=default
export WALLTIME=00:45:00
export PPN=2
export TURBINE_JOBNAME="${EXPID}_job"
# export PROJECT=UrbanExP


# PYTHONPATH
PYTHON_ROOT=/soft/analytics/conda/env/Candle_ML

PATH=$PYTHON_ROOT/bin:$PATH

which python

PP=
PP+=$PYTHON_ROOT/lib/python2.7/site-packages:
PP+=$PYTHON_ROOT/lib/python2.7:
PP+=$P1B1_DIR:
PP+=$PROJECT_ROOT/python

# PYTHONHOME
PH=/soft/analytics/conda/env/Candle_ML

#ENVS="-e EMEWS_PROJECT_ROOT=$EMEWS_PROJECT_ROOT -e PROJECT_ROOT=$PROJECT_ROOT -e PYTHONHOME=$PH -e PYTHONPATH=$PP -e TURBINE_RESIDENT_WORK_WORKERS=1 -e RESIDENT_WORK_RANKS=$(( PROCS - 2 )) -e TURBINE_OUTPUT=$TURBINE_OUTPUT"

ENVS="-e PYTHONHOME=$PH -e PYTHONPATH=$PP -e TURBINE_RESIDENT_WORK_WORKERS=1 -e RESIDENT_WORK_RANKS=$(( PROCS - 2 )) -e PROJECT_ROOT=$PROJECT_ROOT -e EMEWS_PROJECT_ROOT=$EMEWS_PROJECT_ROOT -e TURBINE_OUTPUT=$TURBINE_OUTPUT"

export MODE=cluster
### set the desired number of processors
PROCS=2
###


# set machine to your schedule type (e.g. pbs, slurm, cobalt etc.),
# or empty for an immediate non-queued unscheduled run
# MACHINE="cobalt"

if [ -n "$MACHINE" ]; then
  MACHINE="-m $MACHINE"
fi




# remove -l option for removing printing processors ranks
# settings.json file has all the parameter combinations to be tested
set -x
export TURBINE_LOG=1
echo swift-t  -l -n $PROCS $MACHINE -p $ENVS $EMEWS_PROJECT_ROOT/random-sweep.swift $* --settings=$PWD/../data/settings.json
swift-t  -l -n $PROCS $MACHINE -p $ENVS $EMEWS_PROJECT_ROOT/random-sweep.swift $* --settings=$PWD/../data/settings.json
