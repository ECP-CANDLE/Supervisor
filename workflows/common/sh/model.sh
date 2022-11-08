#!/bin/bash
set -eu

# MODEL.SH

# Shell wrapper around Keras model

# Note: Under Swift/T, the initial output from here will go
# to the main Swift/T stdout and be mixed with output from
# other models.
# Thus, we redirect to a separate model.log file for each model run
# and normally we do not produce output until after the redirection.

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
# TODO: rename INSTANCE_DIRECTORY to OUTPUT_DIR
if [[ $CANDLE_MODEL_TYPE = "SINGULARITY" ]]
then
  INSTANCE_DIRECTORY=$CANDLE_DATA_DIR/output/$EXPID/run/$RUNID
else # "BENCHMARKS"
  INSTANCE_DIRECTORY=$TURBINE_OUTPUT/run/$RUNID
fi

# All stdout/stderr after this point goes into model.log !
mkdir -p $INSTANCE_DIRECTORY
LOG_FILE=$INSTANCE_DIRECTORY/model.log
exec >> $LOG_FILE
exec 2>&1
cd $INSTANCE_DIRECTORY

TIMEOUT_CMD=""
if [[ ${SH_TIMEOUT:-} != "" ]] && [[ $SH_TIMEOUT != "-1" ]]
then
  TIMEOUT_CMD="timeout $SH_TIMEOUT"
fi

log()
{
  echo $( date "+%Y-%m-%d %H:%M:%S" ) "MODEL.SH:" $*
}

log "START"
log "MODEL_NAME: $MODEL_NAME"
log "RUNID: $RUNID"
# log "CANDLE_MODEL_TYPE: $CANDLE_MODEL_TYPE"

# Source langs-app-{SITE} from workflow/common/sh/ (cf. utils.sh)
if [[ ${WORKFLOWS_ROOT:-} == "" ]]
then
  WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
fi
source $WORKFLOWS_ROOT/common/sh/utils.sh
source_site langs-app $SITE

echo
log "PARAMS:"
echo $PARAMS | print_json

echo
log "USING PYTHON:" $( which python )
echo

# Construct the desired model command MODEL_CMD based on CANDLE_MODEL_TYPE:
if [[ $CANDLE_MODEL_TYPE == "SINGULARITY" ]]
then

  # No model_runner, need to write parameters.txt explicitly:
  #  get hyper_parameter_map to pass as 2nd argument

  python3 $WORKFLOWS_ROOT/common/python/runner_utils.py write_params $PARAMS $INIT_PARAMS_FILE
  MODEL_CMD=( singularity exec --nv $CANDLE_IMAGE train.sh $ADLB_RANK_OFFSET
              $CANDLE_DATA_DIR $INSTANCE_DIRECTORY/parameters.txt )
  # train.sh must write $INSTANCE_DIRECTORY/result.txt !
  # or
  # Suggest:

  # Uncomment later
  # grep "CANDLE_RESULT: " $INSTANCE_DIRECTORY/model.log
  # grep "CANDLE_ERROR:"
  # RESULT=$( sed -n '/val_loss:/{s/val_loss: \(.*\)/\1/;p}' | tail -1 )
  # log "found result: $RESULT"
  # echo $RESULT > $INSTANCE_DIRECTORY/result.txt


  # TODO: Add wait for the above and standardize getting results from container.
  echo $MODEL_CMD &
  PID=$!
  # FIX: This doesn't work.
  wait $PID


  # get results of the format Loss: xxx last occurence of in the model.log file
  RESULT=$(awk -v FS="Loss:" 'NF>1{print $2}' model.log | tail -1)
  echo $RESULT > $INSTANCE_DIRECTORY/result.txt

else # "BENCHMARKS"

  # The Python command line arguments:
  PY_CMD=( "$WORKFLOWS_ROOT/common/python/model_runner.py"
           "$PARAMS"
           "$INSTANCE_DIRECTORY"
           "$FRAMEWORK"
           "$RUNID"
           "$BENCHMARK_TIMEOUT" )

  MODEL_CMD=( python3 -u "${PY_CMD[@]}" )
  # model_runner/runner_utils writes result.txt
fi

log "MODEL_CMD: ${MODEL_CMD[@]}"

# Run Python!
if $TIMEOUT_CMD "${MODEL_CMD[@]}"
then
  : # Assume success so we can keep a failed exit code
else
  # $? is the exit status of the most recently executed command
  # (i.e the line in the 'if' condition)
  CODE=$?
  echo # spacer
  if (( $CODE == 124 ))
  then
    log "TIMEOUT ERROR! (timeout=$SH_TIMEOUT)"
    # This will trigger a NaN (the result file does not exist)
    exit 0
  else
    log "MODEL ERROR! (CODE=$CODE)"
    if (( ${IGNORE_ERRORS:-0} ))
    then
      log "IGNORING ERROR."
      # This will trigger a NaN (the result file does not exist)
      exit 0
    fi
    log "ABORTING WORKFLOW (exit 1)"
    exit 1 # Unknown error in Python: abort the workflow
  fi
fi

log "END: SUCCESS"
exit 0 # Success

# Local Variables:
# sh-basic-offset: 2
# End:
