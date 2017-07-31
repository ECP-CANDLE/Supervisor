#! /usr/bin/env bash
set -eu

# TITAN WORKFLOW
# Main entry point for P1B3 mlrMBO workflow

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )

# USER SETTINGS START

# See README.md for more information

BENCHMARK_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot3/P3B1

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
# The default of 4 gives you 2 workers, i.e., 2 concurrent Keras runs
export PROCS=${PROCS:-258}

# MPI processes per node
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-1}
export QUEUE=${QUEUE:-default}
export WALLTIME=${WALLTIME:-05:00:00}

# mlrMBO settings
# How many to runs evaluate per iteration


MAX_BUDGET=${MAX_BUDGET:-1200}
# Total iterations
MAX_ITERATIONS=${MAX_ITERATIONS:-3}
DESIGN_SIZE=${DESIGN_SIZE:-300}
PROPOSE_POINTS=${PROPOSE_POINTS:-300}
PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/parameter_set3.R}
MODEL_NAME="p3b1"
# pbalabra:
# PARAM_SET_FILE="$EMEWS_PROJECT_ROOT/data/parameter_set1.R"

# USER SETTINGS END


# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh
source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh"

script_name=$(basename $0)

# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1

get_expid $* # Sets EXPID

export TURBINE_JOBNAME="${EXPID}_job"

source $WORKFLOWS_ROOT/common/sh/langs-titan.sh

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# EQ/R location
# EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R
EQR=/lustre/atlas2/csc249/proj-shared/sfw/EQ-R

CMD_LINE_ARGS="$* -pp=$PROPOSE_POINTS -mi=$MAX_ITERATIONS -mb=$MAX_BUDGET -ds=$DESIGN_SIZE "
CMD_LINE_ARGS+="-param_set_file=$PARAM_SET_FILE -script_file=$EMEWS_PROJECT_ROOT/scripts/titan_run_model.sh "
CMD_LINE_ARGS+="-exp_id=$EXPID -log_script=$EMEWS_PROJECT_ROOT/../common/sh/titan_run_logger.sh"

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
