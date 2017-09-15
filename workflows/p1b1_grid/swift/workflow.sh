#!/bin/bash
#
# Usage: ./run 
#

# if [ "$#" -ne 1 ]; then
#   script_name=$(basename $0)
#   echo "Usage: ${script_name} EXPERIMENT_ID (e.g. ${script_name} experiment_1)"
#   exit 1
# fi


# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1

usage()
{
  echo "P1B1: usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM"
}

if (( ${#} != 4 ))
then
  usage
  exit 1
fi


#### set this variable to your P1B1 benchmark directory (frameworks branch)
P1B1_DIR=../../../../Benchmarks/Pilot1/P1B1
###

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

THIS=$( cd $( dirname $0 ); /bin/pwd )
export APP_HOME=$THIS

PROJECT_ROOT=$APP_HOME/..

export PYTHONPATH=$PYTHONPATH:$PROJECT_ROOT/python:$P1B1_DIR:$PROJECT_ROOT/../common/python:$PYTHONPATH

export EXPID=$1
export TURBINE_OUTPUT=$APP_HOME/../experiments/$EXPID


# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
export WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
export BENCHMARKS_ROOT=$( cd $EMEWS_PROJECT_ROOT/../../../Benchmarks ; /bin/pwd)
export BENCHMARK_DIR=$BENCHMARKS_ROOT/Pilot1/P1B1
SCRIPT_NAME=$(basename $0)
source $WORKFLOWS_ROOT/common/sh/utils.sh


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





# TODO edit QUEUE, WALLTIME, PPN, AND TURNBINE_JOBNAME
# as required. Note that QUEUE, WALLTIME, PPN, AND TURNBINE_JOBNAME will
# be ignored if MACHINE flag (see below) is not set
export QUEUE=batch
export WALLTIME=00:10:00
export PPN=16
export TURBINE_JOBNAME="${EXPID}_job"

echo $PYTHONPATH

### set the desired number of processors
PROCS=8
###

# remove -l option for removing printing processors ranks
# settings.json file has all the parameter combinations to be tested
echo swift-t  -n $PROCS $APP_HOME/grid-sweep.swift $*
swift-t  -l -n $PROCS $APP_HOME/grid-sweep.swift $* --settings=$PWD/../data/settings.json 