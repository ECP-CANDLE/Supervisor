#!/bin/bash
set -eu

# MODEL.SH

# Shell wrapper around Keras model

usage()
{
  echo "Usage: model.sh [-t TIMEOUT] FRAMEWORK PARAMS RUNID"
  echo "The environment should have SITE MODEL_NAME EXPID BENCHMARK_TIMEOUT"
  echo "If TIMEOUT is provided, we run under the shell command timeout"
}

echo MODEL.SH $*

TIMEOUT=""
while getopts "t:" OPTION
do
  case OPTION in
    t) TIMEOUT=$OPTARG ;;
    *) exit 1 ;; # Bash prints an error message
  esac
done
shift $(( OPTIND - 1 ))

if [ ${#} != 4 ]
then
  usage
  exit 1
fi

FRAMEWORK=$1 # Usually "keras"
shift

# JSON string of parameters
PARAMS="$1"
echo $PARAMS
shift

RUNID=$1
shift

# loss or corr
OBJ_PARAM="$1"
echo $OBJ_PARAM


# Each model run, runs in its own "instance" directory
# Set instance_directory to that and cd into it.
INSTANCE_DIRECTORY=$TURBINE_OUTPUT/run/$RUNID
shift

TIMEOUT_CMD=""
if [ -n "$TIMEOUT" ]; then
  TIMEOUT_CMD="timeout $TIMEOUT"
fi

mkdir -p $INSTANCE_DIRECTORY
LOG_FILE=$INSTANCE_DIRECTORY/model.log
exec >> $LOG_FILE
exec 2>&1
cd $INSTANCE_DIRECTORY

# This output goes in model.log
echo MODEL.SH $*

# get the site and source lang-app-{SITE} from workflow/common/sh folder
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh
source_site langs-app $SITE

echo
echo "USING PYTHON:"
which python

arg_array=( "$WORKFLOWS_ROOT/common/python/model_runner.py"
            "$PARAMS"
            "$INSTANCE_DIRECTORY"
            "$FRAMEWORK"
            "$RUNID"
            "$OBJ_PARAM"
            "$BENCHMARK_TIMEOUT")
MODEL_CMD="python ${arg_array[@]}"
echo MODEL_CMD: $MODEL_CMD
if ! $TIMEOUT_CMD python "${arg_array[@]}"
then
   # $? is the exit status of the most recently executed command
   # (i.e the line above)
   CODE=$?
   if [ $CODE == 124 ]; then
     echo "Timeout error in $MODEL_CMD"
     exit 0 # This will trigger a NaN (the result file does not exist)
   else
     echo "Error in $MODEL_CMD"
     exit 1 # Unknown error in Python: abort the workflow
   fi
fi

exit 0 # Success
