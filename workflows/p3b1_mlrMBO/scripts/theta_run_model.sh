#!/bin/bash

set -eu

# Check for an optional timeout threshold in seconds. If the duration of the
# model run as executed below, takes longer that this threshhold
# then the run will be aborted. Note that the "timeout" command
# must be supported by executing OS.

# The timeout argument is optional. By default the "run_model" swift
# app fuction sends 3 arguments, and no timeout value is set. If there
# is a 4th (the TIMEOUT_ARG_INDEX) argument, we use that as the timeout value.

# !!! IF YOU CHANGE THE NUMBER OF ARGUMENTS PASSED TO THIS SCRIPT, YOU MUST
# CHANGE THE TIMEOUT_ARG_INDEX !!!
TIMEOUT_ARG_INDEX=7
TIMEOUT=""
if [[ $# ==  $TIMEOUT_ARG_INDEX ]]
then
	TIMEOUT=${!TIMEOUT_ARG_INDEX}
fi

TIMEOUT_CMD=""
if [ -n "$TIMEOUT" ]; then
  TIMEOUT_CMD="timeout $TIMEOUT"
fi

parameter_string=$1

# Set emews_root to the root directory of the project (i.e. the directory
# that contains the scripts, swift, etc. directories and files)
emews_root=$2

# Each model run, runs in its own "instance" directory
# Set instance_directory to that and cd into it.
instance_directory=$3
cd $instance_directory

framework=$4
exp_id=$5
run_id=$6

# Theta / Tensorflow env vars
export KMP_BLOCKTIME=30
export KMP_SETTINGS=1
export KMP_AFFINITY=granularity=fine,verbose,compact,1,0
export OMP_NUM_THREADS=144

export PYTHONHOME="/lus/theta-fs0/projects/Candle_ECP/ncollier/py2_tf_gcc6.3_eigen3_native"
PYTHON="$PYTHONHOME/bin/python"
export LD_LIBRARY_PATH="$PYTHONHOME/lib"
export PATH="$PYTHONHOME/bin:$PATH"

BENCHMARK_DIR=$emews_root/../../../Benchmarks/common:$emews_root/../../../Benchmarks/Pilot3/P3B1
COMMON_DIR=$emews_root/../common/python
PYTHONPATH="$PYTHONHOME/lib/python2.7:"
PYTHONPATH+="$BENCHMARK_DIR:$COMMON_DIR:"
PYTHONPATH+="$PYTHONHOME/lib/python2.7/site-packages"
export PYTHONPATH

arg_array=("$emews_root/python/p3b1_runner.py" "$parameter_string" "$instance_directory" "$framework"  "$exp_id" "$run_id")
MODEL_CMD="python ${arg_array[@]}"

msg()
{
  echo "theta_run_model.sh: $*"
}

# Turn bash error checking off. This is
# required to properly handle the model execution return value
# the optional timeout.
set +e

# Format and report model parameters
# as represented on Python command line:
msg MODEL_CMD: $MODEL_CMD | \
  tr -d "{}\""            | \
  tr "," " "              | \
  fmt -t -w 1
echo
$TIMEOUT_CMD $MODEL_CMD
RES=$?
if [ "$RES" -ne 0 ]; then
  if [ "$RES" == 124 ]; then
    msg "---> Timeout error in MODEL_CMD"
  else
    msg "---> Error in MODEL_CMD"
  fi
fi
