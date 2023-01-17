#! /usr/bin/env bash
set -eu

# GA WORKFLOW
# Main entry point for GA workflow
# See README.md for more information

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
export WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
if [[ ! -d $EMEWS_PROJECT_ROOT/../../../Benchmarks ]]
then
  echo "Could not find Benchmarks in: $EMEWS_PROJECT_ROOT/../../../Benchmarks"
  exit 1
fi

export BENCHMARK_TIMEOUT

SCRIPT_NAME=$(basename $0)

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

#source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh" - moved to utils.sh

# Uncomment to turn on Swift/T logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging.
# Do not commit with logging enabled, users have run out of disk space
# export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1

usage()
{
  echo "workflow.sh: usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM MODEL_NAME" \
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
get_expid   $2 $CANDLE_MODEL_TYPE # Sets EXPID
get_cfg_sys $3
get_cfg_prm $4
MODEL_NAME=$5

source_site env   $SITE
source_site sched $SITE

EQPY=${EQPY:-$WORKFLOWS_ROOT/common/ext/EQ-Py}

# Set up PYTHONPATH for model
source $WORKFLOWS_ROOT/common/sh/set-pythonpath.sh

# Set PYTHONPATH for BENCHMARK related stuff
PYTHONPATH+=:$EQPY
PYTHONPATH+=:$WORKFLOWS_ROOT/common/python

export TURBINE_JOBNAME="GA_JOB_${EXPID}"
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


CMD_LINE_ARGS=( -ga_params=$PARAM_SET_FILE
                -seed=$SEED
                -ni=$NUM_ITERATIONS
                -np=$POPULATION_SIZE
                -strategy=$GA_STRATEGY
                -model_sh=$EMEWS_PROJECT_ROOT/scripts/run_model.sh
                -model_name=$MODEL_NAME
                -exp_id=$EXPID
                -benchmark_timeout=$BENCHMARK_TIMEOUT
                -site=$SITE
              )


if [[ ${INIT_PARAMS_FILE:-} != "" ]]
then
  CMD_LINE_ARGS+="-init_params=$INIT_PARAMS_FILE"
fi
USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

#Store scripts to provenance
#copy the configuration files to TURBINE_OUTPUT
cp $WORKFLOWS_ROOT/common/python/$GA_FILE $PARAM_SET_FILE $INIT_PARAMS_FILE  $CFG_SYS $CFG_PRM $TURBINE_OUTPUT


# Make run directory in advance to reduce contention
mkdir -pv $TURBINE_OUTPUT/run

# Allow the user to set an objective function
OBJ_DIR=${OBJ_DIR:-$WORKFLOWS_ROOT/common/swift}
OBJ_MODULE=${OBJ_MODULE:-obj_$SWIFT_IMPL}
# This is used by the obj_app objective function
export MODEL_SH=$WORKFLOWS_ROOT/common/sh/model.sh

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

#swift-t -n $PROCS \
#        -o $TURBINE_OUTPUT/workflow.tic \
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

(
set -x
swift-t -O 0 -n $PROCS \
        ${MACHINE:-} \
        -p -I $EQPY -r $EQPY \
        -I $OBJ_DIR \
        -i $OBJ_MODULE \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
        -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
        -e BENCHMARKS_ROOT \
        -e EMEWS_PROJECT_ROOT \
        $( python_envs ) \
        -e APP_PYTHONPATH \
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
        $EMEWS_PROJECT_ROOT/swift/workflow.swift ${CMD_LINE_ARGS[@]} |& \
    tee $STDOUT
)

if (( ${PIPESTATUS[0]} ))
then
  echo "workflow.sh: swift-t exited with error!"
  exit 1
fi

echo "EXIT CODE: 0" | tee -a $STDOUT

# Andrew: Needed this so that script to monitor job worked properly (queue_wait... function in utils.sh?)
echo $TURBINE_OUTPUT > turbine-directory.txt
