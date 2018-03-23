#!/bin/bash
set -eu

# MODEL.SH

# Shell wrapper around Keras model

usage()
{
  echo "Usage: model.sh FRAMEWORK PARAMS RUNID"
  echo "The environment should have:"
  echo "  SITE MODEL_NAME EXPID BENCHMARK_TIMEOUT OBJ_RETURN"
  echo "If TIMEOUT is provided, we run under the shell command timeout"
}

if (( ${#} != 3 ))
then
  usage
  exit 1
fi

FRAMEWORK=$1 # Usually "keras"
# JSON string of parameters
PARAMS="$2"
RUNID=$3

# Each model run, runs in its own "instance" directory
# Set instance_directory to that and cd into it.
INSTANCE_DIRECTORY=$TURBINE_OUTPUT/run/$RUNID

SH_TIMEOUT=${SH_TIMEOUT:-}
TIMEOUT_CMD=""
if [[ -n "$SH_TIMEOUT" ]] && [[ $SH_TIMEOUT != "-1" ]]
then
  TIMEOUT_CMD="timeout $SH_TIMEOUT"
fi

# All stdout/stderr after this point goes into model.log !
mkdir -p $INSTANCE_DIRECTORY
LOG_FILE=$INSTANCE_DIRECTORY/model.log
exec >> $LOG_FILE
exec 2>&1
cd $INSTANCE_DIRECTORY

echo MODEL.SH

# get the site and source lang-app-{SITE} from workflow/common/sh folder
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh
source_site langs-app $SITE

echo
echo PARAMS:
echo $PARAMS | print_json

echo
echo "USING PYTHON:"
which python

set -x
arg_array=( "$WORKFLOWS_ROOT/common/python/model_runner.py"
            "$PARAMS"
            "$INSTANCE_DIRECTORY"
            "$FRAMEWORK"
            "$RUNID"
            "$BENCHMARK_TIMEOUT")
MODEL_CMD="python -u ${arg_array[@]}"
# echo MODEL_CMD: $MODEL_CMD
if $TIMEOUT_CMD python -u "${arg_array[@]}"
then
  : # Assume success so we can keep a failed exit code
else
  # $? is the exit status of the most recently executed command
  # (i.e the line in the 'if' condition)
  CODE=$?
  if [ $CODE == 124 ]; then
    echo "MODEL.SH: Timeout error in $MODEL_CMD"
    exit 0 # This will trigger a NaN (the result file does not exist)
  else
    echo "MODEL.SH: Error in $MODEL_CMD"
    exit 1 # Unknown error in Python: abort the workflow
  fi
fi

echo "MODEL.SH END: SUCCESS"
exit 0 # Success
