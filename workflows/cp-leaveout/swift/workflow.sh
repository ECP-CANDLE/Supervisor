#! /usr/bin/env bash
set -eu

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

SCRIPT_NAME=$(basename $0)

export FRAMEWORK="keras"

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

usage()
{
  echo "workflow.sh: usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM MODEL_NAME"
}

if (( ${#} < 5 ))
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
 }
then
  usage
  exit 1
fi

shift 5
WORKFLOW_ARGS=$*

echo "WORKFLOW.SH: Running model: $MODEL_NAME for EXPID: $EXPID"

source_site env   $SITE
source_site sched $SITE

PYTHONPATH+=:$EMEWS_PROJECT_ROOT/py            # For plangen, data_setup
PYTHONPATH+=:$WORKFLOWS_ROOT/common/python     # For log_tools
APP_PYTHONPATH+=:$EMEWS_PROJECT_ROOT/py        # For plangen, data_setup
APP_PYTHONPATH+=:$WORKFLOWS_ROOT/common/python # For log_tools
APP_PYTHONPATH+=:$BENCHMARK_DIR:$BENCHMARKS_ROOT/common # For Benchmarks

export TURBINE_JOBNAME="JOB:${EXPID}"

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
                $GPU_ARG
                $WORKFLOW_ARGS
              )

USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

# Make run directory in advance to reduce contention
mkdir -p $TURBINE_OUTPUT/run

# Allow the user to set an objective function
OBJ_DIR=${OBJ_DIR:-$WORKFLOWS_ROOT/common/swift}
OBJ_MODULE=${OBJ_MODULE:-obj_$SWIFT_IMPL}
# This is used by the obj_app objective function
export MODEL_SH=$WORKFLOWS_ROOT/common/sh/model.sh

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

swift-t -O 0 -n $PROCS \
        ${MACHINE:-} \
        -p -I $EQR -r $EQR \
        -I $OBJ_DIR \
        -i $OBJ_MODULE \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e BENCHMARKS_ROOT \
        -e EMEWS_PROJECT_ROOT \
        -e APP_PYTHONPATH=$APP_PYTHONPATH \
        $( python_envs ) \
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
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

if (( ${PIPESTATUS[0]} ))
then
  echo "workflow.sh: swift-t exited with error!"
  exit 1
fi

echo "WORKFLOW OK."
echo "EXIT CODE: 0" | tee -a $STDOUT
