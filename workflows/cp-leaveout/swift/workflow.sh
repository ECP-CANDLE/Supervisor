#! /usr/bin/env bash
set -eu
shopt -s nullglob

# CP-LEAVEOUT WORKFLOW
# Main entry point for CP-LEAVEOUT workflow
# See README.adoc for more information

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
export WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
if [[ ! -d $EMEWS_PROJECT_ROOT/../../../Benchmarks ]]
then
  echo "Could not find Benchmarks in: $EMEWS_PROJECT_ROOT/../../../Benchmarks"
  exit 1
fi
BENCHMARKS_DEFAULT=$( cd $EMEWS_PROJECT_ROOT/../../../Benchmarks ; /bin/pwd)
export BENCHMARKS_ROOT=${BENCHMARKS_ROOT:-${BENCHMARKS_DEFAULT}}
BENCHMARKS_DIR_BASE=$BENCHMARKS_ROOT/Pilot1/Uno
export BENCHMARK_TIMEOUT
export BENCHMARK_DIR=${BENCHMARK_DIR:-$BENCHMARKS_DIR_BASE}

export PYTHONPATH=${PYTHONPATH:-}:$BENCHMARK_DIR:$BENCHMARKS_ROOT/Pilot1/Uno

SCRIPT_NAME=$(basename $0)

export FRAMEWORK="keras"

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

usage()
{
  echo "workflow.sh: usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM MODEL_NAME EPOCH_MODE"
  echo "             EPOCH_MODE is one of the compute_epochs_*.swift modules."
}

if (( ${#} < 6 ))
then
  usage
  exit 1
fi

if ! {
  get_site    $1 # Sets SITE
  get_expid   $2 # Sets EXPID
  get_cfg_sys $3
  get_cfg_prm $4
  MODEL_NAME=$5
  EPOCH_MODE=$6
 }
then
  usage
  exit 1
fi

shift 6
WORKFLOW_ARGS=$*

echo "WORKFLOW.SH: Running model: $MODEL_NAME for EXPID: $EXPID"

if [[ ${CANDLE_DATA_DIR:-} == "" ]]
then
  echo "workflow.sh: You must set CANDLE_DATA_DIR"
  exit 1
fi

source_site env   $SITE
source_site sched $SITE

# Note: insist on plangen from Supervisor!
PYTHONPATH=$EMEWS_PROJECT_ROOT/py:$PYTHONPATH  # For plangen, data_setup
PYTHONPATH+=:$WORKFLOWS_ROOT/common/python     # For log_tools, model_runner
APP_PYTHONPATH+=:$EMEWS_PROJECT_ROOT/py        # For plangen, data_setup
APP_PYTHONPATH+=:$WORKFLOWS_ROOT/common/python # For log_tools
APP_PYTHONPATH+=:$BENCHMARK_DIR:$BENCHMARKS_ROOT/common # For Benchmarks
export APP_PYTHONPATH

# Job name limit on Frontier: 8
export TURBINE_JOBNAME=$EXPID

if [ -z ${GPU_STRING+x} ];
then
  GPU_ARG=""
else
  GPU_ARG="-gpus=$GPU_STRING"
fi

export DB_FILE=$TURBINE_OUTPUT/cplo.db

if [[ ! -f DB_FILE ]]
then
  if [[ ${CPLO_ID:-} == "" ]]
  then
    if [[ ${EXPID:0:1} == "X" ]]
    then
      export CPLO_ID=${EXPID:1}
    else
      export CPLO_ID=$EXPID
    fi
  fi
  # Doing this in workflow now:
  # $EMEWS_PROJECT_ROOT/db/db-cplo-init $DB_FILE $CPLO_ID
fi

CMD_LINE_ARGS=( --benchmark_timeout=$BENCHMARK_TIMEOUT
                --site=$SITE
                --db_file=$DB_FILE
                --user=$USER
                $GPU_ARG
                $WORKFLOW_ARGS
              )

if [[ $WORKFLOW_ARGS = "-r"* ]]
then
  echo "Restart requested ..."
  if [[ ! -d $TURBINE_OUTPUT ]]
  then
    echo "ERROR: No prior run found! (tried $TURBINE_OUTPUT)"
    exit 1
  fi
  if [[ ! -f $TURBINE_OUTPUT/cplo.db ]]
  then
    echo "ERROR: No DB found! (tried $TURBINE_OUTPUT/cplo.db)"
    exit 1
  fi
  if [[ ! -f $TURBINE_OUTPUT/output.txt ]]
  then
    # If output.txt does not exist, assume the moves already happened
    echo "WARNING: The outputs were already moved from $EXPID"
  else
    next "$TURBINE_OUTPUT/restarts/%02i" # cf. utils.sh:next()
    PRIOR_RUN=$REPLY
    echo "Moving old outputs to $PRIOR_RUN"
    mkdir -pv $PRIOR_RUN
    PRIORS=( $TURBINE_OUTPUT/output.txt
             $TURBINE_OUTPUT/out
             $TURBINE_OUTPUT/turbine*
             $TURBINE_OUTPUT/jobid.txt*
             $TURBINE_OUTPUT/plangen_db.log* )
    mv ${PRIORS[@]} $PRIOR_RUN
    cp $TURBINE_OUTPUT/cplo.db $PRIOR_RUN
  fi
else # Not a restart
  if [[ -f $TURBINE_OUTPUT/output.txt ]]
  then
    echo "TURBINE_OUTPUT already exists- you must specify restart!"
    echo "TURBINE_OUTPUT=$TURBINE_OUTPUT"
    exit 1
  fi
fi

USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

# Make run directory in advance to reduce contention
mkdir -p $TURBINE_OUTPUT/run

# Allow the user to set an objective function
CANDLE_MODEL_DIR=${CANDLE_MODEL_DIR:-$WORKFLOWS_ROOT/common/swift}
CANDLE_MODEL_MODULE=${CANDLE_MODEL_MODULE:-model_$CANDLE_MODEL_IMPL}
# This is used by the obj_app objective function
export MODEL_SH=$WORKFLOWS_ROOT/common/sh/model.sh

EPOCH_MODE_MODULE="compute_epochs_$EPOCH_MODE"

if [[ ! -f swift/$EPOCH_MODE_MODULE.swift ]]
then
  abort "workflow.sh: No such EPOCH_MODE: swift/$EPOCH_MODE_MODULE.swift"
fi

WORKFLOW_SWIFT=${WORKFLOW_SWIFT:-workflow.swift}
echo "WORKFLOW_SWIFT: $WORKFLOW_SWIFT"

WAIT_ARG=""
if (( ${WAIT:-0} ))
then
  WAIT_ARG="-t w"
  echo "Turbine will wait for job completion."
fi

#echo ${CMD_LINE_ARGS[@]}

if [[ ${MACHINE:-} == "" ]]
then
  # Why? -Justin 2019-05-31
  # rm turbine-output
  :
fi

which python swift-t java

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

TURBINE_STDOUT=""
if [[ $SITE == "summit" || $SITE == "frontier" ]]
then
  export TURBINE_STDOUT="$TURBINE_OUTPUT/out/out-%%r.txt"
else
  export TURBINE_STDOUT="$TURBINE_OUTPUT/out/out-%r.txt"
fi
mkdir -pv $TURBINE_OUTPUT/out

LD_LIBRARY_PATH=/opt/cray/libfabric/1.15.2.0/lib64

export MODEL_RETURN="val_loss"

export TURBINE_LEADER_HOOK_STARTUP="$( sed 's/#.*//;s/$/;/' $EMEWS_PROJECT_ROOT/swift/hook-1.tcl )"

# Environment variables KEY=VALUE passed into workflow.
# If exported, a VALUE does not need to be provided.
ENVS=(
  # Where the Benchmarks are:
  BENCHMARKS_ROOT
  # The top-level directory for this workflow:
  EMEWS_PROJECT_ROOT
  PYTHONPATH=/home/wozniak/.local/lib/python3.9/site-packages
  # This will be pre-pended into PYTHONPATH if model.sh is used:
  APP_PYTHONPATH
  # Tell Python to auto-flush stdout:
  PYTHONUNBUFFERED=1
  # Other site-specific Python settings:
  # $( python_envs )
  # The CANDLE model:
  MODEL_PYTHON_SCRIPT=${MODEL_PYTHON_SCRIPT:-}
  MODEL_PYTHON_DIR=${MODEL_PYTHON_DIR:-}
  # Location of model.sh:
  MODEL_SH
  # The CANDLE model name:
  MODEL_NAME
  # The statistic to return from each model:
  MODEL_RETURN
  # The computing site we are running on:
  SITE
  # A timeout in seconds for each model:
  BENCHMARK_TIMEOUT
  SH_TIMEOUT
  # If 1, do not crash workflow on model errors:
  IGNORE_ERRORS
)

# Number of ranks to allocate for the DB:
export TURBINE_DB_WORKERS=1

# Insert -e flags for Swift/T command line:
ENV_ARG="-e $( echo ${ENVS[@]} | sed 's/  */ -e /g' )"

export TURBINE_LOG=0

module list
swift-t -O 0 -n $PROCS \
        ${MACHINE:-} \
        -p \
        -I $CANDLE_MODEL_DIR \
        -i $CANDLE_MODEL_MODULE \
        -I $EMEWS_PROJECT_ROOT/swift \
        -i $EPOCH_MODE_MODULE \
        ${ENV_ARG} \
        $WAIT_ARG \
        $EMEWS_PROJECT_ROOT/swift/$WORKFLOW_SWIFT ${CMD_LINE_ARGS[@]}
  # | \
  # tee $STDOUT

# -e LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-} \
# -e USER # Needed on Summit to find NVME
# -j /usr/bin/java # Give this to Swift/T if needed for Java
# -e PYTHONVERBOSE=1    # Debugs module load confusion


if (( ${PIPESTATUS[0]} ))
then
  echo "workflow.sh: swift-t exited with error!"
  exit 1
fi

# # Check job output
# TURBINE_OUTPUT=$( readlink turbine-output )
# OUTPUT=turbine-output/output.txt
# WORKFLOW=$( basename $EMEWS_PROJECT_ROOT )

# # Wait for job
# queue_wait

# SCRIPT=$( basename $0 .sh )
# check_output "EXIT CODE: 0" $OUTPUT $WORKFLOW $SCRIPT $JOBID

echo "WORKFLOW OK."
echo "EXIT CODE: 0" | tee -a $STDOUT
