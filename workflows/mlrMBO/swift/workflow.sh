#! /usr/bin/env bash
set -eu

# MLRMBO WORKFLOW
# Main entry point for mlrMBO workflow
# See README.md for more information

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
export WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
export BENCHMARK_TIMEOUT

SCRIPT_NAME=$(basename $0)

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

usage()
{
  echo "workflow.sh: usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM MODEL_NAME " \
       "[CANDLE_MODEL_TYPE] [CANDLE_IMAGE]"
}

if (( ${#} != 7 )) && (( ${#} != 5 ))
then
  usage
  exit 1
fi

if (( ${#} == 7 ))
then
  export CANDLE_MODEL_TYPE=$6
  export CANDLE_IMAGE=$7
elif (( ${#} == 5 ))
then
  CANDLE_MODEL_TYPE="BENCHMARKS"
  CANDLE_IMAGE=NONE
else
  usage
  exit 1
fi

TURBINE_OUTPUT=""
if [[ $CANDLE_MODEL_TYPE = "SINGULARITY" ]]
then
  TURBINE_OUTPUT=$CANDLE_DATA_DIR/output
  printf "Running mlrMBO workflow with model %s and image %s:%s\n" \
         $MODEL_NAME $CANDLE_MODEL_TYPE $CANDLE_IMAGE
fi

get_site    $1 # Sets SITE
get_expid   $2 # Sets EXPID
get_cfg_sys $3
get_cfg_prm $4
MODEL_NAME=$5

source_site env   $SITE
source_site sched $SITE

if [[ ${EQR:-} == "" ]]
then
  abort "The site '$SITE' did not set the location of EQ/R: " \
        "this will not work!"
fi

# Set up PYTHONPATH for model
source $WORKFLOWS_ROOT/common/sh/set-pythonpath.sh

export TURBINE_JOBNAME="MBO_${EXPID}"

RESTART_FILE_ARG=""
if [[ ${RESTART_FILE:-} != "" ]]
then
  RESTART_FILE_ARG="--restart_file=$RESTART_FILE"
fi

RESTART_NUMBER_ARG=""
if [[ ${RESTART_NUMBER:-} != "" ]]
then
  RESTART_NUMBER_ARG="--restart_number=$RESTART_NUMBER"
fi

R_FILE_ARG=""
if [[ ${R_FILE:-} == "" ]]
then
  R_FILE="mlrMBO1.R"
fi

R_FILE_ARG="--r_file=$R_FILE"

CMD_LINE_ARGS=( -param_set_file=$PARAM_SET_FILE
                -mb=$MAX_BUDGET
                -ds=$DESIGN_SIZE
                -pp=$PROPOSE_POINTS
                -it=$MAX_ITERATIONS
                -exp_id=$EXPID
                -benchmark_timeout=$BENCHMARK_TIMEOUT
                -site=$SITE
                $RESTART_FILE_ARG
                $RESTART_NUMBER_ARG
                $R_FILE_ARG
              )

USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

#Store scripts to provenance
#copy the configuration files and R file (for mlrMBO params) to TURBINE_OUTPUT
cp $WORKFLOWS_ROOT/common/R/$R_FILE $PARAM_SET_FILE $CFG_SYS $CFG_PRM $TURBINE_OUTPUT

# Make run directory in advance to reduce contention
mkdir -pv $TURBINE_OUTPUT/run

# Allow the user to set an objective function
CANDLE_MODEL_IMPL=${CANDLE_MODEL_IMPL:-container}
OBJ_DIR=${OBJ_DIR:-$WORKFLOWS_ROOT/common/swift}
OBJ_MODULE=${OBJ_MODULE:-model_$CANDLE_MODEL_IMPL}
# This is used by the obj_app objective function
# Andrew: Allows for custom model.sh file, if that's desired
export MODEL_SH=${MODEL_SH:-$WORKFLOWS_ROOT/common/sh/model.sh}

WAIT_ARG=""
if (( ${WAIT:-0} ))
then
  WAIT_ARG="-t w"
  echo "Turbine will wait for job completion."
fi

# Handle %-escapes in TURBINE_STDOUT
if [ $SITE == "summit"  ] || \
   [ $SITE == "biowulf" ] || \
   [ $SITE == "polaris" ]
then
  export TURBINE_STDOUT="$TURBINE_OUTPUT/out/out-%%r.txt"
else
  export TURBINE_STDOUT="$TURBINE_OUTPUT/out/out-%r.txt"
fi

mkdir -pv $TURBINE_OUTPUT/out

if [[ ${MACHINE:-} == "" ]]
then
  STDOUT=$TURBINE_OUTPUT/output.txt
  # The turbine-output link is only created on scheduled systems,
  # so if running locally, we create it here so the test*.sh wrappers
  # can find it
  [[ -L turbine-output ]] && rm turbine-output
  ln -s $TURBINE_OUTPUT turbine-output
else
  # When running on a scheduled system, Swift/T automatically redirects
  # stdout to the turbine-output directory.  This will just be for
  # warnings or unusual messages
  STDOUT=""
fi

if [[ ${CANDLE_DATA_DIR:-} == "" ]]
then
  echo "CANDLE_DATA_DIR is not set in the environment!  Exiting..."
  exit 1
fi

# We use 'swift-t -o' to allow swift-t to prevent scheduler errors
# on Biowulf.  Reported by ALW 2021-01-21

(
set -x
swift-t -O 0 -n $PROCS \
        -o $TURBINE_OUTPUT/workflow.tic \
        ${MACHINE:-} \
        -p -I $EQR -r $EQR \
        -I $OBJ_DIR \
        -i $OBJ_MODULE \
        -e LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-} \
        -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
        -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
        -e APP_PYTHONPATH \
        -e BENCHMARKS_ROOT \
        -e EMEWS_PROJECT_ROOT \
        $( python_envs ) \
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        -e OBJ_RETURN \
        -e MODEL_PYTHON_SCRIPT=${MODEL_PYTHON_SCRIPT:-} \
        -e MODEL_PYTHON_DIR=${MODEL_PYTHON_DIR:-} \
        -e MODEL_SH \
        -e MODEL_NAME \
        -e SITE \
        -e BENCHMARK_TIMEOUT \
        -e SH_TIMEOUT \
        -e TURBINE_STDOUT \
        -e IGNORE_ERRORS \
        -e CANDLE_DATA_DIR \
        -e CANDLE_MODEL_TYPE \
        -e CANDLE_IMAGE \
        $WAIT_ARG \
        $EMEWS_PROJECT_ROOT/swift/workflow.swift ${CMD_LINE_ARGS[@]} ) 2>&1 | \
  tee $STDOUT

if (( ${PIPESTATUS[0]} ))
then
  echo "workflow.sh: swift-t exited with error!"
  exit 1
fi

echo "EXIT CODE: 0" | tee -a $STDOUT
