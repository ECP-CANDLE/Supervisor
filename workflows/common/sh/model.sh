#!/bin/bash
set -eu

# MODEL.SH

# Supervisor shell wrapper around CANDLE model
# Used for CANDLE_MODEL_IMPL types: "app" and "container"

# The result number is written to $PWD/result.txt,
#     and additionally to a file in optional environment
#     variable RESULT_FILE

# Note that APP_PYTHONPATH is used by models here and
# not just PYTHONPATH

# Note: Under Swift/T, the initial output from here will go
# to the main Swift/T stdout and be mixed with output from
# other models.
# Thus, we redirect to a separate model.log file for each model run
# and normally we do not produce output until after the redirection.

usage()
{
  echo "Usage: model.sh FRAMEWORK PARAMS EXPID RUNID MODEL_TYPE MODEL_NAME MODEL_ACTION"
  echo "MODEL_TYPE is BENCHMARK or SINGULARITY"
  echo "MODEL_NAME is the CANDLE Benchmark name (e.g., 'uno')"
  echo "           or a /path/to/image.sif"
  echo "MODEL_ACTION is unused for a Benchmark,"
  echo "             for Singularity it is a script (e.g., 'ACTION.sh')"
  echo "The environment should have:"
  echo "                EMEWS_PROJECT_ROOT|WORKFLOWS_ROOT TURBINE_OUTPUT"
  echo "                SITE MODEL_RETURN BENCHMARK_TIMEOUT"
  echo "                CANDLE_DATA_DIR"
  echo "If SH_TIMEOUT is set, we run under the shell command timeout"
}

if (( ${#} != 7 ))
then
  echo
  echo "model.sh: Wrong number of arguments: received ${#} , required: 7"
  echo
  usage
  exit 1
fi

FRAMEWORK=$1 # Usually "keras" or "pytorch"
# JSON string of parameters:
PARAMS="$2"
export EXPID=$3
export RUNID=$4
export MODEL_TYPE=$5
export MODEL_NAME=$6
export MODEL_ACTION=$7

# Each model run runs in its own "run directory"
if [[ $MODEL_TYPE = "SINGULARITY" ]]
then
  # TODO: Rename "instance" to "run"
  MODEL_TOKEN=$( basename $MODEL_NAME .sif )
  # The container will create subdirectories based on
  #               --experiment_id and --run_id
  # This directory is bound inside the container:
  export CANDLE_OUTPUT_DIR=/candle_data_dir/$MODEL_TOKEN/Output
  # This directory is outside the container:
  RUN_DIRECTORY=$CANDLE_DATA_DIR/$MODEL_TOKEN/Output/$EXPID/$RUNID
  mkdir -pv $RUN_DIRECTORY
else # "BENCHMARKS"
  RUN_DIRECTORY=$TURBINE_OUTPUT/$RUNID
  mkdir -pv $RUN_DIRECTORY
  export CANDLE_OUTPUT_DIR=$( realpath --canonicalize-existing \
                                       $RUN_DIRECTORY )
fi

# All stdout/stderr after this point goes into model.log !
LOG_FILE=$RUN_DIRECTORY/model.log
echo "redirecting to: LOG_FILE=$LOG_FILE"
set +x
exec >> $LOG_FILE
exec 2>&1
cd $RUN_DIRECTORY

TIMEOUT_CMD=""
if [[ ${SH_TIMEOUT:-} != "" ]] && [[ $SH_TIMEOUT != "-1" ]]
then
  TIMEOUT_CMD="timeout $SH_TIMEOUT"
fi

log "START"
log "MODEL_NAME: $MODEL_NAME"
log "RUNID: $RUNID"
log "HOST: $( hostname )"

# ADLB variables are set by Swift/T/ADLB:
# http://swift-lang.github.io/swift-t/guide.html#turbine_env2
# CVD is CUDA_VISIBLE_DEVICES
CVD=$(( $ADLB_RANK_OFFSET + ${CANDLE_CUDA_OFFSET:-0} ))
log "ADLB_RANK_SELF:   $ADLB_RANK_SELF"
log "ADLB_RANK_OFFSET: $ADLB_RANK_OFFSET"
log "CUDA DEVICE:      $CVD"
log "MODEL_TYPE:       $MODEL_TYPE"

# Source langs-app-{SITE} from workflow/common/sh/ (cf. utils.sh)
if [[ ${WORKFLOWS_ROOT:-} == "" ]]
then
  WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
fi
source $WORKFLOWS_ROOT/common/sh/utils.sh
LOG_NAME="MODEL.SH"
source_site langs-app $SITE

echo
log "PARAMS:"
echo $PARAMS | print_json

echo
log "USING PYTHON:" $( which python3 )
echo

# Cf. utils.sh
log_path APP_PYTHONPATH
log_path PYTHONPATH
log_path LD_LIBRARY_PATH
show     PYTHONHOME

# Set up PYTHONPATH for app tasks
export PYTHONPATH=${APP_PYTHONPATH:-}:${PYTHONPATH:-}

# Construct the desired model command MODEL_CMD based on MODEL_TYPE:
if [[ ${MODEL_TYPE:-} == "SINGULARITY" ]]
then

  # No model_runner, need to write parameters.txt explicitly:
  #  get hyper_parameter_map to pass as 2nd argument

  FLAGS=$( python3 $WORKFLOWS_ROOT/common/python/runner_utils.py expand_params \
                   "$PARAMS" )

  # Remove --candle image flag and the second argument, assume it is the last argument
  export FLAGS="${FLAGS/ --candle_image*/}"

  # The Singularity command line arguments:
  MODEL_CMD=( singularity exec --nv
              --bind $CANDLE_DATA_DIR:/candle_data_dir
              $MODEL_NAME ${MODEL_ACTION}.sh $CVD
              /candle_data_dir
              $FLAGS
              --experiment_id $EXPID
              --run_id $RUNID
            )

else # "BENCHMARKS"

  # The Python command line arguments:
  PY_CMD=( "$WORKFLOWS_ROOT/common/python/model_runner.py"
           "$PARAMS"
           "$RUN_DIRECTORY"
           "$FRAMEWORK"
           "$RUNID"
           "$BENCHMARK_TIMEOUT" )

  MODEL_CMD=( python3 -u "${PY_CMD[@]}" )
  # model_runner/runner_utils writes result.txt
fi

echo
log "MODEL_CMD: ${MODEL_CMD[@]}"
echo

# Run Python!
$TIMEOUT_CMD "${MODEL_CMD[@]}" &
PID=$!

# Use if block to suppress errors:
if wait $PID
then
  CODE=0
else
  CODE=$?
fi

log "$MODEL_TYPE: EXIT CODE: $CODE"
if (( CODE == 0 ))
then
  echo PWD: $( pwd -P )
  echo RUN_DIRECTORY: $RUN_DIRECTORY
  ls -ltrh
  sleep 1  # Wait for initial output
  # Get last results of the format "IMPROVE RESULT xxx" in model.log
  # NOTE: Enabling set -x will break the following (token CANDLE_RESULT)
  RES=$( awk -v FS="IMPROVE_RESULT" 'NF>1 {x=$2} END {print x}' \
             $RUN_DIRECTORY/model.log )
  RESULT="$(echo $RES | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')" || true
  echo "IMPROVE RESULT: '$RESULT'"
  echo $RESULT > $RUN_DIRECTORY/result.txt
  if [[ ${RESULT_FILE:-} != "" ]]
  then
    echo $RESULT > $RESULT_FILE
  fi
else
  echo # spacer
  if (( $CODE == 124 ))
  then
    log "TIMEOUT ERROR! (timeout=$SH_TIMEOUT)"
  else
    log "MODEL ERROR! (CODE=$CODE)"
  fi
  if (( ${IGNORE_ERRORS:-0} == 0 ))
  then
    # Unknown error in Python: abort the workflow
    log "ABORTING WORKFLOW (exit 1)"
    exit 1
  fi
  # This will trigger a NaN (the result file does not exist)
  log "IGNORING ERROR."
fi

log "END: SUCCESS"

exit 0 # Success

# Local Variables:
# sh-basic-offset: 2
# End:
