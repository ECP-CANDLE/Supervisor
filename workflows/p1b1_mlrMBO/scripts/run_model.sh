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
TIMEOUT_ARG_INDEX=10
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

echo "run_model: PWD=$PWD"

model_name=$4
framework=$5
exp_id=$6
run_id=$7
benchmark_timeout=$8

# get the site and source lang-app-{SITE} from workflow/common/sh folder
WORKFLOWS_ROOT=$emews_root/..
SITE=$9

TIMEOUT=$10
if (( $TIMEOUT >= 0 ))
then
  TIMEOUT_CMD="timeout $TIMEOUT"
else
  TIMEOUT_CMD=""
fi

source $WORKFLOWS_ROOT/common/sh/utils.sh
source_site langs-app $SITE

arg_array=("$emews_root/python/p1b1_runner.py" "$parameter_string" "$instance_directory" "$model_name" "$framework"  "$exp_id" "$run_id" "$benchmark_timeout")
echo ${arg_array[@]}
MODEL_CMD="python ${arg_array[@]}"

# Turn bash error checking off. This is
# required to properly handle the model execution return value
# the optional timeout.
set +e
# echo $MODEL_CMD

echo "python starting"

$TIMEOUT_CMD python "${arg_array[@]}"
# Get exit code from timeout/Python
RES=$?

echo "python done."

if [ "$RES" -ne 0 ]; then
  if [ "$RES" == 124 ]; then
    echo "---> Timeout error in $MODEL_CMD"
    exit 0 # This will trigger a NaN (the result file does not exist)
  else
    echo "---> Error in $MODEL_CMD"
  #  exit 1 # Unknown error in Python: abort the workflow
  fi
fi

exit 0 # Success
