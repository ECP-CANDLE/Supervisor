#! /usr/bin/env bash
set -eu

# BASELINE ERROR SH
# Main entry point for baseline-error workflow
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

PYTHONPATH=${PYTHONPATH:-}:$BENCHMARK_DIR

SCRIPT_NAME=$(basename $0)

export FRAMEWORK="keras"

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

usage()
{
  echo "baseline-error.sh:" \
       "usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM MODEL_NAME "
}

if (( ${#} < 5 ))
then
  usage
  exit 1
fi

set -x
if ! {
  get_site    $1 # Sets SITE
  get_expid   $2 # Sets EXPID
  get_cfg_sys $3
  get_cfg_prm $4
  MODEL_NAME=$5
 }
then
  usage
  exit 1
fi

shift 5
WORKFLOW_ARGS=$*

echo "WORKFLOW.SH: Running model: $MODEL_NAME for EXPID: $EXPID"

set +x

source_site env   $SITE
source_site sched $SITE

PYTHONPATH+=:$EMEWS_PROJECT_ROOT/py            # For plangen, data_setup
PYTHONPATH+=:$WORKFLOWS_ROOT/common/python     # For log_tools, model_runner
APP_PYTHONPATH+=:$EMEWS_PROJECT_ROOT/py        # For plangen, data_setup
APP_PYTHONPATH+=:$WORKFLOWS_ROOT/common/python # For log_tools
APP_PYTHONPATH+=:$BENCHMARK_DIR:$BENCHMARKS_ROOT/common # For Benchmarks

export TURBINE_JOBNAME="JOB:${EXPID}"

if [[ ${GPU_STRING:-} == "" ]]
then
  GPU_ARG=""
else
  GPU_ARG="-gpus=$GPU_STRING"
fi

CMD_LINE_ARGS=( --benchmark_timeout=$BENCHMARK_TIMEOUT
                --site=$SITE
                $GPU_ARG
                $WORKFLOW_ARGS
              )

if [[ $WORKFLOW_ARGS = "-r"* ]]
then
  echo "Restart requested ..."
  if [[ ! -d $TURBINE_OUTPUT ]]
  then
    echo "No prior run found!  (tried $TURBINE_OUTPUT/output.txt)"
    exit 1
  fi
  if [[ ! -f $TURBINE_OUTPUT/output.txt ]]
  then
    # If output.txt does not exist, assume the moves already happened
    echo "WARNING: The outputs were already moved from $EXPID"
  else
    next $TURBINE_OUTPUT/restarts/%i # cf. utils.sh:next()
    PRIOR_RUN=$REPLY
    echo "Moving old outputs to $PRIOR_RUN"
    mkdir -pv $PRIOR_RUN
    PRIORS=( $TURBINE_OUTPUT/output.txt
             $TURBINE_OUTPUT/out
             $TURBINE_OUTPUT/turbine*
             $TURBINE_OUTPUT/jobid.txt )
    mv    ${PRIORS[@]}            $PRIOR_RUN
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
OBJ_DIR=${OBJ_DIR:-$WORKFLOWS_ROOT/common/swift}
OBJ_MODULE=${OBJ_MODULE:-model_$CANDLE_MODEL_IMPL}
# This is used by the obj_app objective function
export MODEL_SH=$WORKFLOWS_ROOT/common/sh/model.sh

WORKFLOW_SWIFT=${WORKFLOW_SWIFT:-baseline-error.swift}
echo "WORKFLOW_SWIFT: $WORKFLOW_SWIFT"

WAIT_ARG=""
if (( ${WAIT:-0} ))
then
  WAIT_ARG="-t w"
  echo "Turbine will wait for job completion."
fi

# which python swift-t java

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

TURBINE_STDOUT="$TURBINE_OUTPUT/out/out-%%r.txt"
mkdir -pv $TURBINE_OUTPUT/out

swift-t -O 0 -n $PROCS \
        ${MACHINE:-} \
        -p \
        -I $OBJ_DIR \
        -i $OBJ_MODULE \
        -I $EMEWS_PROJECT_ROOT/swift \
        -e LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-} \
        -e BENCHMARKS_ROOT \
        -e EMEWS_PROJECT_ROOT \
        -e APP_PYTHONPATH=$APP_PYTHONPATH \
        $( python_envs ) \
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        -e TURBINE_STDOUT=$TURBINE_STDOUT \
        -e OBJ_RETURN \
        -e MODEL_PYTHON_SCRIPT=${MODEL_PYTHON_SCRIPT:-} \
        -e MODEL_PYTHON_DIR=${MODEL_PYTHON_DIR:-} \
        -e MODEL_SH \
        -e MODEL_NAME \
        -e SITE \
        -e BENCHMARK_TIMEOUT \
        -e BENCHMARKS_ROOT \
        -e SH_TIMEOUT \
        -e IGNORE_ERRORS \
        -e TURBINE_DB_WORKERS=1 \
        $WAIT_ARG \
        $EMEWS_PROJECT_ROOT/swift/$WORKFLOW_SWIFT ${CMD_LINE_ARGS[@]} | \
  tee $STDOUT

# -j /usr/bin/java # Give this to Swift/T if needed for Java
# -e PYTHONUNBUFFERED=1 # May be needed if error output is being lost

if (( ${PIPESTATUS[0]} ))
then
  echo "workflow.sh: swift-t exited with error!"
  exit 1
fi

echo "WORKFLOW OK."
echo "EXIT CODE: 0" | tee -a $STDOUT
