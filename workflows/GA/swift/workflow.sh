#! /usr/bin/env bash
set -eu

# GA WORKFLOW
# Main entry point for GA workflow
# See README.md for more information

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
export WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
export BENCHMARK_TIMEOUT BENCHMARKS_ROOT

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
  echo "GA/workflow.sh: usage:"
  echo "workflow.sh SITE TEST_SCRIPT                      _or_"
  echo "workflow.sh SITE CFG_SYS CFG_PRM MODEL_NAME       _or_"
  echo "workflow.sh SITE CFG_SYS CFG_PRM MODEL_NAME CANDLE_MODEL_TYPE SIF"
  echo
  echo "The 2-argument case is used by the supervisor tool."
  echo "The 5-argument case is best for plain Python cases."
  echo "The 7-argument case is best for Singularity container cases."
}


if (( ${#} == 0 ))
then
  usage
  exit 1
fi
get_site $1 # Sets SITE
if (( ${#} == 2 ))
then
  : ${CANDLE_MODEL_TYPE:=BENCHMARKS}
  : ${CANDLE_IMAGE:=NONE}
  TEST_SCRIPT=$2
  # Sets EXPID.  If EXPID=="" , applies -a
  get_expid ${EXPID:--a}
  source_cfg -v $TEST_SCRIPT
elif (( ${#} == 5 ))
then
  get_expid   $2 # Sets EXPID
  get_cfg_sys $3
  get_cfg_prm $4
  MODEL_NAME=$5
  : ${CANDLE_MODEL_TYPE:=BENCHMARKS}
  : ${CANDLE_IMAGE:=NONE}
elif (( ${#} == 7 ))
then
  get_expid   $2 # Sets EXPID
  get_cfg_sys $3
  get_cfg_prm $4
  MODEL_NAME=$5
  export CANDLE_MODEL_TYPE=$6
  export CANDLE_IMAGE=$7
else
  usage
  exit 1
fi
: ${CANDLE_MODEL_TYPE:=BENCHMARKS}
if [[ $CANDLE_MODEL_TYPE = "SINGULARITY" ]]
then
  TURBINE_OUTPUT=$CANDLE_DATA_DIR/output
  printf "Running GA workflow with model %s and model type %s\n" \
         $MODEL_NAME $CANDLE_MODEL_TYPE
fi
mkdir -p $TURBINE_OUTPUT

source_site env   $SITE
source_site sched $SITE

: ${EQPY:=$WORKFLOWS_ROOT/common/ext/EQ-Py}

# Set up PYTHONPATH for model
source $WORKFLOWS_ROOT/common/sh/set-pythonpath.sh

# Set PYTHONPATH for BENCHMARK related stuff
PYTHONPATH+=:$EQPY
PYTHONPATH+=:$WORKFLOWS_ROOT/common/python

export TURBINE_JOBNAME=$EXPID
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

if [[ ${SEED:-} == "" ]]
then
  # Auto-generate SEED based on clock (nanos) and PID
  # Use 10# to force value to decimal (cannot have leading 0s)
  #SEED=$(( ( 10#$(date +%N) + ${$}) % 1000000 ))
SEED=$(date +%s%N)
SEED=${SEED%N}  # Remove trailing N
SEED=$(($SEED + $$))
SEED=$((SEED % 1000000))
fi

# Defaults for GA/DEAP:
: ${NUM_ITERATIONS:=3} ${POPULATION_SIZE:=3} ${STRATEGY:=mu_plus_lambda}
: ${OFFSPRING_PROPORTION:=0.5} ${MUT_PROB:=0.8} ${CX_PROB:=0.2}
: ${MUT_INDPB:=0.5} ${CX_INDPB:=0.5} ${TOURNSIZE:=4}
# Miscellaneous defaults:
: ${BENCHMARK_TIMEOUT:=-1} ${SH_TIMEOUT:=-1} ${IGNORE_ERRORS:=0}
: ${MODEL_RETURN:=val_loss}
export MODEL_NAME MODEL_RETURN SH_TIMEOUT IGNORE_ERRORS
export CANDLE_MODEL_TYPE

if ! find_cfg $PARAM_SET_FILE
then
  crash "Could not find PARAM_SET_FILE: $PARAM_SET_FILE"
fi
PARAM_SET_FILE=$REPLY

CMD_LINE_ARGS=( -ga_params=$PARAM_SET_FILE
                -seed=$SEED
                -ni=$NUM_ITERATIONS
                -np=$POPULATION_SIZE
                -strategy=$STRATEGY
                -off_prop=$OFFSPRING_PROPORTION
                -mut_prob=$MUT_PROB
                -cx_prob=$CX_PROB
                -mut_indpb=$MUT_INDPB
                -cx_indpb=$CX_INDPB
                -tournsize=$TOURNSIZE
                -model_sh=$EMEWS_PROJECT_ROOT/scripts/run_model.sh
                -model_name=$MODEL_NAME
                -exp_id=$EXPID
                -benchmark_timeout=$BENCHMARK_TIMEOUT
                -site=$SITE
              )

export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

if [[ ${INIT_PARAMS_FILE:-} != "" ]]
then
  CMD_LINE_ARGS+="-init_params=$INIT_PARAMS_FILE"
fi
USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

#Store scripts to provenance
cp $PARAM_SET_FILE ${INIT_PARAMS_FILE:-} $TURBINE_OUTPUT

# Make run directory in advance to reduce contention
mkdir -pv $TURBINE_OUTPUT/run

if [[ ${CANDLE_MODEL_TYPE:-} == "SINGULARITY" ]]
then
  CANDLE_MODEL_IMPL="container"
  BENCHMARKS_ROOT=""
fi

SWIFT_LIBS_DIR=${SWIFT_LIBS_DIR:-$WORKFLOWS_ROOT/common/swift}
SWIFT_MODULE=${SWIFT_MODULE:-model_$CANDLE_MODEL_IMPL}
# This is used by the candle_model_train_app function
export MODEL_SH=$WORKFLOWS_ROOT/common/sh/model.sh

WAIT_ARG=""
if (( ${WAIT:-0} ))
then
  WAIT_ARG="-t w"
  echo "Turbine will wait for job completion."
fi

# Handle %-escapes in TURBINE_STDOUT
if [[ $SITE == "summit"   ]] || \
   [[ $SITE == "biowulf"  ]] || \
   [[ $SITE == "polaris"  ]] || \
   [[ $SITE == "frontier" ]]
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
  crash "CANDLE_DATA_DIR is not set in the environment!"
fi

(
  which python swift-t
  swift-t -O 0 -n $PROCS \
          ${MACHINE:-} \
          -p -I $EQPY -r $EQPY \
          -I $SWIFT_LIBS_DIR \
          -i $SWIFT_MODULE \
          -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
          -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
          -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
          -e BENCHMARKS_ROOT \
          -e EMEWS_PROJECT_ROOT \
          $( python_envs ) \
          -e APP_PYTHONPATH \
          -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
          -e MODEL_RETURN \
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
          $WAIT_ARG \
          $EMEWS_PROJECT_ROOT/swift/workflow.swift ${CMD_LINE_ARGS[@]}
)

if (( ${PIPESTATUS[0]} ))
then
  echo "workflow.sh: swift-t exited with error!"
  exit 1
fi

echo "EXIT CODE: 0" | tee -a $STDOUT
