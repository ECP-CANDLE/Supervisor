#! /usr/bin/env bash
set -eu

# Autodetect this workflow directory
export APP_HOME=$( cd $( dirname $0 ) ; /bin/pwd )

#### set this variable to add new benchmarks directory
RUNNERS_DIR=$APP_HOME/../../../../Benchmarks/Pilot1/P1B1:$APP_HOME/../../../../Benchmarks/Pilot2/P2B1:$APP_HOME/../../../../Benchmarks/Pilot3/P3B1:$APP_HOME/../../../../Benchmarks/Pilot1/NT3:$APP_HOME/../../../../Benchmarks/Pilot1/P1B3
###
# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
# The default of 4 gives you 2 workers, i.e., 2 concurrent Keras runs
export PROCS=${PROCS:-36}
# MPI processes per node
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-1}
export QUEUE=${QUEUE:-default}
export WALLTIME=${WALLTIME:-01:20:00}


if [ "$#" -ne 4 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} EXPERIMENT_ID (run1_p1b1) BENCHMARKS_NAME (eg. p1b1) SEARCH_TYPE (eg. grid or random) INPUT_JSON"
  echo "Example: ./run p1b1_experiment1 p1b1 random p1b1_settings.json"
  echo "-This creates a p1b1_experiment1 directory in ../experiments"
  echo " uses random scheme for variables specified in ../data/p1b1_settings.json file"
  exit 1
fi

# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1

export EXPID=$1
export B_NAME=$2
export S_NAME=$3
export JSON_F=$4

export TURBINE_OUTPUT=$APP_HOME/../experiments/$EXPID
export PROJECT=Candle_ECP
export TURBINE_JOBNAME="${EXPID}_job"

TCL=/home/wozniak/Public/sfw/theta/tcl-8.6.1
export R=/home/wozniak/Public/sfw/theta/R-3.4.0/lib64/R
export PY=/home/rjain/anaconda2
export LD_LIBRARY_PATH=$PY/lib:$R/lib:$LD_LIBRARY_PATH
COMMON_DIR=$APP_HOME/../../common/python
PYTHONPATH=$APP_HOME/../python:$RUNNERS_DIR:$COMMON_DIR
PYTHONHOME=/home/rjain/anaconda2

export PATH=/home/rjain/install/stc/bin:$TCL/bin:$PATH
#$PYTHONHOME/bin:$TCL/bin:$PATH

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))


TURBINE_DIR=/home/rjain/install/turbine/lib

# set machine to your scheduler type (e.g. pbs, slurm, cobalt etc.),
# or empty for an immediate non-queued unscheduled run
MACHINE="theta"

if [ -n "$MACHINE" ]; then
  MACHINE="-m $MACHINE"
fi

set -x
WORKFLOW_SWIFT=rnd_or_grid.swift
swift-t -n $PROCS $MACHINE -r $TURBINE_DIR \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
    -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
    -e APP_HOME=$APP_HOME \
    -e PYTHONPATH=$PYTHONPATH \
    -e PYTHONHOME=$PYTHONHOME \
    -e TURBINE_DEBUG=$TURBINE_DEBUG\
    -e ADLB_DEBUG=$ADLB_DEBUG \
    -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        $APP_HOME/$WORKFLOW_SWIFT  --benchmark_name=$B_NAME --search_type=$S_NAME --input_file=$JSON_F &
