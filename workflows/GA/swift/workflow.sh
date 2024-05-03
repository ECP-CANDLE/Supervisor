#! /usr/bin/env bash
set -eu

# GA WORKFLOW
# Main entry point for GA workflow
# See README.md for more information

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
export WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
export SUPERVISOR_HOME=$( cd $WORKFLOWS_ROOT/.. ; /bin/pwd )

SCRIPT_NAME=$(basename $0)

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

# Uncomment to allow Swift/T logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging.
# Do not commit with logging enabled, users have run out of disk space
# export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1

# Environment Variables
# See the swift-t -e K=V arguments for the list of relevant
# environment variables.  These are forwarded into the Swift/T
# execution environment.  Other environment variables are usually not
# be forwarded, depending on the system scheduler.

log "GA WORKFLOW.SH ..."

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

export VERBOSITY=${VERBOSITY:-0}

if (( ${#} == 0 ))
then
  usage
  exit 1
fi

# TODO: CANDLE_IMAGE is unused.
#       We construct the SIF name from MODEL_NAME in model.sh
#       Remove it.  --Justin 2024-04-25

get_site $1 # Sets SITE
if (( ${#} == 2 ))
then
  # This is used by bin/supervisor
  : ${CANDLE_MODEL_TYPE:=BENCHMARKS}
  : ${CANDLE_IMAGE:=NONE}
  TEST_SCRIPT=$2
  source_cfg -v $TEST_SCRIPT
  TEST_SCRIPT=$REPLY
  get_expid ${EXPID:--a}  # Sets EXPID
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
  CANDLE_MODEL_TYPE=$6
  export CANDLE_IMAGE=$7
else
  usage
  exit 1
fi

if [[ $CANDLE_MODEL_TYPE == "SINGULARITY" ]]
then
  TOKEN=$( basename $MODEL_NAME .sif )
  TURBINE_OUTPUT=$CANDLE_DATA_DIR/output/$TOKEN/$EXPID
else
  TOKEN=$MODEL_NAME
fi

log "MODEL_TYPE:" $CANDLE_MODEL_TYPE
log "MODEL_NAME:" $MODEL_NAME
log "EXPERIMENT OUTPUT DIRECTORY:" $TURBINE_OUTPUT

sv_path_append $EMEWS_PROJECT_ROOT/data
sv_path_append $SUPERVISOR_HOME/workflows/common/sh

find_cfg $PARAM_SET_FILE
PARAM_SET_FILE=$REPLY

if ! [[ -f $PARAM_SET_FILE ]]
then
  echo "workflow.sh: could not find $PARAM_SET_FILE"
  exit 1
fi

mkdir -p $TURBINE_OUTPUT
# Store hyperparameters and make output.csv file with columns
EXP_DIR=$CANDLE_DATA_DIR/$TOKEN/Output/$EXPID # Establishing where to put
mkdir -pv $EXP_DIR
touch $EXP_DIR/output.csv # output file
grep -oP '"name": "\K[^"]*' $PARAM_SET_FILE | awk '{printf "%s,", $0}' >> $EXP_DIR/output.csv # get hyperparams for csv file columns
echo "run_id,val_loss" >> $EXP_DIR/output.csv # add run_id and val_loss to csv file columns

# Copy configuration to experiment directory:
cp $PARAM_SET_FILE $TEST_SCRIPT $EXP_DIR
# Use PARAM_SET_FILE from EXP_DIR (for concurrent workflows)
PARAM_SET_FN=$( basename $PARAM_SET_FILE )
PARAM_SET_FILE=$EXP_DIR/$PARAM_SET_FN

source_site -vv env   $SITE
source_site -o  sched $SITE

# Set up PYTHONPATH for model
source $WORKFLOWS_ROOT/common/sh/set-pythonpath.sh

# Set job name for scheduler
export TURBINE_JOBNAME=$EXPID

if [[ ${SEED:-} == "" ]]
then
  # Auto-generate SEED based on clock (nanos) and PID
  SEED=$(date +%s%N)
  SEED=${SEED%N}  # Remove trailing N
  SEED=$(($SEED + $$))
  SEED=$((SEED % 1000000))
fi

# Defaults for GA/DEAP:
: ${NUM_ITERATIONS:=3} ${POPULATION_SIZE:=3} ${STRATEGY:=mu_plus_lambda}
: ${OFFSPRING_PROPORTION:=0.5} ${MUT_PROB:=0.8} ${CX_PROB:=0.2}
: ${MUT_INDPB:=0.5} ${CX_INDPB:=0.5} ${TOURNSIZE:=4}
# Model execution defaults:
: ${BENCHMARK_TIMEOUT:=-1} ${SH_TIMEOUT:=-1} ${IGNORE_ERRORS:=0}
: ${BENCHMARKS_ROOT:=}
: ${MODEL_PYTHON_SCRIPT:=} ${MODEL_PYTHON_DIR:=}
: ${MODEL_RETURN:=val_loss}

export BENCHMARK_TIMEOUT SH_TIMEOUT IGNORE_ERRORS \
       BENCHMARKS_ROOT \
       MODEL_NAME MODEL_PYTHON_SCRIPT MODEL_PYTHON_DIR MODEL_RETURN \
       CANDLE_MODEL_TYPE

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
                -model_name=$MODEL_NAME
                -exp_id=$EXPID
                -benchmark_timeout=$BENCHMARK_TIMEOUT
                -site=$SITE
              )

# Reserve a rank for DEAP:
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

if [[ ${INIT_PARAMS_FILE:-} != "" ]]
then
  CMD_LINE_ARGS+="-init_params=$INIT_PARAMS_FILE"
fi
USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

# Make run directory in advance to reduce contention
mkdir -pv $TURBINE_OUTPUT/run

if [[ ${CANDLE_MODEL_TYPE:-} == "SINGULARITY" ]]
then
  CANDLE_MODEL_IMPL="container"
  BENCHMARKS_ROOT=""
fi

# Needed for EQPy.swift
: ${EQPY:=$WORKFLOWS_ROOT/common/ext/EQ-Py}

# Set up Swift/T imports:
SWIFT_LIBS_DIR=${SWIFT_LIBS_DIR:-$WORKFLOWS_ROOT/common/swift}
SWIFT_MODULE=${SWIFT_MODULE:-model_$CANDLE_MODEL_IMPL}

# This is used by the Swift/T function candle_model_train():
export MODEL_SH=$WORKFLOWS_ROOT/common/sh/model.sh

WAIT_ARG=""
if (( ${WAIT:-0} ))
then
  WAIT_ARG="-t w"
  echo "Turbine will wait for job completion."
fi

# Some systems have issues with %-escapes
# Handle %-escapes in TURBINE_STDOUT
if [[ $SITE == "summit"       ]] || \
   [[ $SITE == "biowulf"      ]] || \
   [[ $SITE == "frontier"     ]] || \
   [[ "$MACHINE"  == "-m pbs" ]]
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
          -e LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-} \
          -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
          -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
          -e BENCHMARKS_ROOT \
          -e EMEWS_PROJECT_ROOT \
          $( python_envs ) \
          -e APP_PYTHONPATH \
          -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
          -e MODEL_RETURN \
          -e MODEL_PYTHON_SCRIPT \
          -e MODEL_PYTHON_DIR \
          -e MODEL_NAME \
          -e MODEL_SH \
          -e SITE \
          -e BENCHMARK_TIMEOUT \
          -e SH_TIMEOUT \
          -e TURBINE_STDOUT \
          -e IGNORE_ERRORS \
          -e CANDLE_DATA_DIR \
          -e CANDLE_MODEL_TYPE \
          -e CANDLE_FRAMEWORK \
          $WAIT_ARG \
          $EMEWS_PROJECT_ROOT/swift/workflow.swift ${CMD_LINE_ARGS[@]}
)

if (( ${PIPESTATUS[0]} ))
then
  log "GA WORKFLOW.SH: swift-t exited with error!"
  exit 1
fi

log "GA WORKFLOW.SH: DONE." | tee -a $STDOUT
