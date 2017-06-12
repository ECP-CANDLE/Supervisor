#! /usr/bin/env bash
set -eu

# CORI WORKFLOW
# Main entry point for P2B1 mlrMBO workflow

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )

# USER SETTINGS START

# See ../README.adoc for more information

# The directory in the Benchmarks repo containing P1B3
BENCHMARK_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot2/P2B1

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
# The default of 4 gives you 2 workers, i.e., 2 concurrent Keras runs
export PROCS=${PROCS:-4}

# MPI processes per node
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-4}

# See http://www.nersc.gov/users/computational-systems/cori/running-jobs/queues-and-policies/
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
source $EMEWS_PROJECT_ROOT/etc/emews_utils.sh
source $WORKFLOWS_ROOT/common/sh/utils.sh

# Obtain settings for Cori
source $WORKFLOWS_ROOT/common/sh/cori.sh

PYTHONPATH=$PYTHONPATH:$HOME/.local/cori/deeplearning2.7/lib/python2.7/site-packages

# See utils.sh
get_expid $*
export TURBINE_JOBNAME="${EXPID}_job"

export KERAS_BACKEND=theano

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# EQ/R location
EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R

CMD_LINE_ARGS="$* -pp=$MAX_CONCURRENT_EVALUATIONS -it=$MAX_ITERATIONS "
CMD_LINE_ARGS+="-param_set_file=$PARAM_SET_FILE "

# Echos anything following this to stderr
set -x
WORKFLOW_SWIFT=workflow.swift
swift-t -n $PROCS $MACHINE -p -I $EQR -r $EQR \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        $EMEWS_PROJECT_ROOT/swift/$WORKFLOW_SWIFT $CMD_LINE_ARGS
