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
TIMEOUT_ARG_INDEX=4
TIMEOUT=""
if [[ $# ==  $TIMEOUT_ARG_INDEX ]]
then
	TIMEOUT=${!TIMEOUT_ARG_INDEX}
fi

TIMEOUT_CMD=""
if [ -n "$TIMEOUT" ]; then
  TIMEOUT_CMD="timeout $TIMEOUT"
fi

# Set param_line from the first argument to this script
# param_line is the string containing the model parameters for a run.
param_file=$1

# Set emews_root to the root directory of the project (i.e. the directory
# that contains the scripts, swift, etc. directories and files)
emews_root=$2

# Each model run, runs in its own "instance" directory
# Set instance_directory to that and cd into it.
instance_directory=$3
cd $instance_directory

# TODO: Define the command to run the model
#VERSION="$(<$emews_root/../Release/version.txt)"
#APP=$emews_root/../Release/transmission_model-$VERSION
#PROPS_FILE=$emews_root/../config/model.props
# TODO configure python correctly
# export PYTHONPATH=$emews_root/python:$benchmark_path
PYTHON="/home/pbalapra/anaconda2/envs/idp/bin/python"
export LD_LIBRARY_PATH="/home/pbalapra/anaconda2/envs/idp/lib"
export PATH="/home/pbalapra/anaconda2/envs/idp/bin:$PATH"
export PYTHONHOME="/home/pbalapra/anaconda2/envs/idp"
export PYTHONPATH="/home/pbalapra/anaconda2/envs/idp/lib/python2.7:/home/ncollier/repos/Benchmarks/Pilot1/P1B3"
MODEL_CMD="python $emews_root/python/p1b3_runner.py $param_file $instance_directory"

# Turn bash error checking off. This is
# required to properly handle the model execution return value
# the optional timeout.
set +e
echo $MODEL_CMD
$TIMEOUT_CMD $MODEL_CMD
# $? is the exit status of the most recently executed command (i.e the
# line above)
RES=$?
if [ "$RES" -ne 0 ]; then
	if [ "$RES" == 124 ]; then
    echo "---> Timeout error in $MODEL_CMD"
  else
	   echo "---> Error in $MODEL_CMD"
  fi
fi
