#!/bin/bash
set -eu

# MODEL.SH

# Shell wrapper around Keras model

usage()
{
  echo "Usage: model.sh FRAMEWORK PARAMS RUNID"
  echo "The environment should have:"
  echo "  EMEWS_PROJECT_ROOT|WORKFLOWS_ROOT TURBINE_OUTPUT"
  echo "  SITE OBJ_RETURN BENCHMARK_TIMEOUT"
  echo "  and MODEL_NAME EXPID for model_runner.py"
  echo "If SH_TIMEOUT is provided, we run under the shell command timeout"
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

echo "MODEL.SH START:"
echo "MODEL_NAME: $MODEL_NAME"
echo "RUNID: $RUNID"

# Source langs-app-{SITE} from workflow/common/sh/ (cf. utils.sh)
if [[ ${WORKFLOWS_ROOT:-} == "" ]]
then
  WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
fi
source $WORKFLOWS_ROOT/common/sh/utils.sh
source_site langs-app $SITE

echo
echo PARAMS:
echo $PARAMS | print_json

echo
echo "MODEL.SH: USING PYTHON:"
which python
echo

arg_array=( "$WORKFLOWS_ROOT/common/python/model_abstention_runner.py"
            "$PARAMS"
            "$INSTANCE_DIRECTORY"
            "$FRAMEWORK"
            "$RUNID"
            "$BENCHMARK_TIMEOUT")
MODEL_CMD="python3 -u ${arg_array[@]}"
# echo MODEL_CMD: $MODEL_CMD
if $TIMEOUT_CMD python3 -u "${arg_array[@]}"
then
  : # Assume success so we can keep a failed exit code
else
  # $? is the exit status of the most recently executed command
  # (i.e the line in the 'if' condition)
  CODE=$?
  echo # spacer
  if [ $CODE == 124 ]
  then
    echo "MODEL.SH: Timeout error in $MODEL_CMD"
    # This will trigger a NaN (the result file does not exist)
    exit 0
  else
    echo "MODEL.SH: Error (CODE=$CODE) in $MODEL_CMD"
    echo "MODEL.SH: TIMESTAMP:" $( date "+%Y-%m-%d %H:%M:%S" )
    if (( ${IGNORE_ERRORS:-0} ))
    then
      echo "MODEL.SH: IGNORING ERROR."
      # This will trigger a NaN (the result file does not exist)
      exit 0
    fi
    echo "MODEL.SH: ABORTING WORKFLOW (exit 1)"
    exit 1 # Unknown error in Python: abort the workflow
  fi
fi

echo "MODEL.SH END: SUCCESS"
exit 0 # Success

# Local Variables:
# sh-basic-offset: 2
# End:
