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
TIMEOUT_ARG_INDEX=9
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

mkdir -p $instance_directory
log_file=$instance_directory/run_model.log
exec >> $log_file
exec 2>&1
cd $instance_directory

echo "theta_run_model: PWD=$PWD"

model_name=$4
framework=$5
exp_id=$6
run_id=$7
benchmark_timeout=$8

# Theta / Tensorflow env vars
export KMP_BLOCKTIME=30
export KMP_SETTINGS=1
export KMP_AFFINITY=granularity=fine,verbose,compact,1,0
export OMP_NUM_THREADS=128

export PYTHONHOME="/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/"
PYTHON="$PYTHONHOME/bin/python"
#export LD_LIBRARY_PATH="$PYTHONHOME/lib"
export LD_LIBRARY_PATH=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/lib:/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/cuda/lib64:/opt/gcc/4.9.3/snos/lib64:/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3x/lib64/R/lib

export PATH="$PYTHONHOME/bin:$PATH"

BENCHMARK_DIR=$emews_root/../../../Benchmarks/common:$emews_root/../../../Benchmarks/Pilot1/NT3
COMMON_DIR=$emews_root/../common/python
PYTHONPATH="$PYTHONHOME/lib/python2.7:"
PYTHONPATH+="$BENCHMARK_DIR:$COMMON_DIR:"
PYTHONPATH+="$PYTHONHOME/lib/python2.7/site-packages"
export PYTHONPATH

arg_array=("$emews_root/python/nt3_tc1_runner.py" "$parameter_string" "$instance_directory" "$model_name" "$framework"  "$exp_id" "$run_id" "$benchmark_timeout")
MODEL_CMD="python ${arg_array[@]}"

# Turn bash error checking off. This is
# required to properly handle the model execution return value
# the optional timeout.
set +e
# echo $MODEL_CMD

echo "python starting"

$TIMEOUT_CMD python "${arg_array[@]}"

echo "python done."

RES=$?
if [ "$RES" -ne 0 ]; then
  if [ "$RES" == 124 ]; then
    echo "---> Timeout error in $MODEL_CMD"
    exit 0 # This will trigger a NaN (the result file does not exist)
  else
    echo "---> Error in $MODEL_CMD"
    exit 1 # Unknown error in Python: abort the workflow
  fi
fi

exit 0 # Success
