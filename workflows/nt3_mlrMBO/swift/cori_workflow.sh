#! /usr/bin/env bash
set -eu

# CORI WORKFLOW
# Main entry point for P1B3 mlrMBO workflow

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )

# USER SETTINGS START

# See README.md for more information

# The directory in the Benchmarks repo containing NT3
BENCHMARK_DIR="$EMEWS_PROJECT_ROOT/../../../Benchmarks/common"
BENCHMARK_DIR="$BENCHMARK_DIR:$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot1/NT3"
BENCHMARK_DIR="$BENCHMARK_DIR:$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot1/TC1"

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
# The default of 4 gives you 2 workers, i.e., 2 concurrent Keras runs
export PROCS=${PROCS:-10}

# MPI processes per node
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-2}

# See http://www.nersc.gov/users/computational-systems/cori/running-jobs/queues-and-policies/
export QUEUE=${QUEUE:-debug}
export WALLTIME=${WALLTIME:-00:30:00}

# mlrMBO settings
# How many to runs evaluate per iteration
MAX_CONCURRENT_EVALUATIONS=${MAX_CONCURRENT_EVALUATIONS:-8}
# Total iterations
MAX_ITERATIONS=${MAX_ITERATIONS:-16}
PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/parameter_set.R}
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
export TURBINE_OUTPUT_ROOT=${TURBINE_OUTPUT_ROOT:-$EMEWS_PROJECT_ROOT/experiments}
export TURBINE_OUTPUT=$TURBINE_OUTPUT_ROOT/$EXPID
check_directory_exists

export TURBINE_JOBNAME="${EXPID}_job"

# if R cannot be found, then these will need to be
# uncommented and set correctly.
# export R_HOME=/path/to/R
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$R_HOME/lib
# export PYTHONHOME=

# BENCHMARK_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot1/nt3:$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot1/tc1
export R_HOME=/global/u1/w/wozniak/Public/sfw/R-3.4.0/lib64/R/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/global/u1/w/wozniak/Public/sfw/R-3.4.0/lib64/R/lib
COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
export PYTHONPATH=$BENCHMARK_DIR:$COMMON_DIR:$EMEWS_PROJECT_ROOT/python
export PYTHONHOME=/global/common/cori/software/python/2.7-anaconda/envs/deeplearning/

export TURBINE_DIRECTIVE="#SBATCH --constraint=knl,quad,cache\n#SBATCH --license=SCRATCH\n#SBATCH --account=m2759"

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# EQ/R location
EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R

CMD_LINE_ARGS="$* -pp=$MAX_CONCURRENT_EVALUATIONS -it=$MAX_ITERATIONS "
CMD_LINE_ARGS+="-param_set_file=$PARAM_SET_FILE -model_name=$MODEL_NAME "
CMD_LINE_ARGS+="-exp_id=$EXPID "

# set machine to your scheduler type (e.g. pbs, slurm, cobalt etc.),
# or empty for an immediate non-queued unscheduled run
MACHINE="slurm"

if [ -n "$MACHINE" ]; then
  MACHINE="-m $MACHINE"
fi

# Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=("VAR_1" "VAR_2")
USER_VARS=($CMD_LINE_ARGS)
# log variables and script to to TURBINE_OUTPUT directory
log_script

R_LIB=/global/homes/w/wozniak/Public/sfw/R-3.4.0/lib64/R/lib
GCC_LIB=/opt/gcc/6.3.0/snos/lib64

# echo's anything following this to standard out
set -x
WORKFLOW_SWIFT=workflow.swift
swift-t -n $PROCS $MACHINE -p -I $EQR -r $EQR \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$R_LIB:$GCC_LIB \
        $EMEWS_PROJECT_ROOT/swift/$WORKFLOW_SWIFT $CMD_LINE_ARGS
