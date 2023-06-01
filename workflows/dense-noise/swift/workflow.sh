#! /usr/bin/env bash
set -eu

# DENSE NOISE WORKFLOW
# Main entry point for DENSE-NOISE workflow
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
BENCHMARKS_DIR_BASE=$BENCHMARKS_ROOT/Pilot1/NT3
export BENCHMARK_TIMEOUT
export BENCHMARK_DIR=${BENCHMARK_DIR:-$BENCHMARKS_DIR_BASE}

SCRIPT_NAME=$(basename $0)

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

usage()
{
  echo "workflow.sh: usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM MODEL_NAME"
}

if (( ${#} != 5 ))
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

echo "workflow.sh start: MODEL_NAME=$MODEL_NAME"

source_site env   $SITE
source_site sched $SITE

# Set PYTHONPATH for BENCHMARK related stuff
PYTHONPATH+=:$WORKFLOWS_ROOT/common/python  # needed for model_runner

export TURBINE_JOBNAME="${EXPID}"

if [[ ${CANDLE_DATA_DIR:-} == "" ]]
then
  echo "workflow.sh: CANDLE_DATA_DIR is not set!"
  exit 1
fi

if [ -z ${GPU_STRING+x} ];
then
  GPU_ARG=""
else
  GPU_ARG="-gpus=$GPU_STRING"
fi

mkdir -pv $TURBINE_OUTPUT

# Set up PYTHONPATH for model
source $WORKFLOWS_ROOT/common/sh/set-pythonpath.sh

CMD_LINE_ARGS=( -benchmark_timeout=$BENCHMARK_TIMEOUT
                -exp_id=$EXPID
                -site=$SITE
              )

USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

# Make run directory in advance to reduce contention
mkdir -pv $TURBINE_OUTPUT/run
mkdir -pv $TURBINE_OUTPUT/data

# CANDLE_MODEL_IMPL: "container" on Polaris, "py" on Summit/Frontier
CANDLE_MODEL_IMPL="container"

# Allow the user to set an objective function
SWIFT_LIBS_DIR=${OBJ_DIR:-$WORKFLOWS_ROOT/common/swift}
SWIFT_MODULE=${OBJ_MODULE:-model_$CANDLE_MODEL_IMPL}
# This is used by the obj_app objective function
export MODEL_SH=$WORKFLOWS_ROOT/common/sh/model.sh

# log_path PYTHONPATH

WORKFLOW_SWIFT=${WORKFLOW_SWIFT:-workflow.swift}
echo "WORKFLOW_SWIFT: $WORKFLOW_SWIFT"

WAIT_ARG=""
if (( ${WAIT:-0} ))
then
  WAIT_ARG="-t w"
  echo "Turbine will wait for job completion."
fi

# Output handline
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
  # stdout to the turbine-output directory.
  # Some systems do % interpretation in environment variables,
  #              we escape them in TURBINE_STDOUT here:
  if [[ $SITE == "summit"  ]] || \
     [[ $SITE == "biowulf" ]] || \
     [[ $SITE == "polaris" ]]
  then
    : # export TURBINE_STDOUT="$TURBINE_OUTPUT/out/out-%%r.txt"
  else
    : # export TURBINE_STDOUT="$TURBINE_OUTPUT/out/out-%r.txt"
  fi
  STDOUT=""
fi

cd $TURBINE_OUTPUT
cp $CFG_SYS $CFG_PRM $TURBINE_OUTPUT

swift-t -n $PROCS \
        ${MACHINE:-} \
        -p \
        -I $SWIFT_LIBS_DIR \
        -i $SWIFT_MODULE \
        -e LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-} \
        -e TURBINE_STDOUT \
        -e BENCHMARKS_ROOT \
        -e EMEWS_PROJECT_ROOT \
        -e APP_PYTHONPATH=$APP_PYTHONPATH \
        $( python_envs ) \
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        -e MODEL_RETURN \
        -e CANDLE_DATA_DIR \
        -e MODEL_PYTHON_SCRIPT=${MODEL_PYTHON_SCRIPT:-} \
        -e MODEL_PYTHON_DIR=${MODEL_PYTHON_DIR:-} \
        -e MODEL_SH \
        -e MODEL_NAME \
        -e SITE \
        -e BENCHMARK_TIMEOUT \
        -e BENCHMARKS_ROOT \
        -e SH_TIMEOUT \
        -e IGNORE_ERRORS \
        $WAIT_ARG \
        $EMEWS_PROJECT_ROOT/swift/$WORKFLOW_SWIFT ${CMD_LINE_ARGS[@]} 2>&1 | \
  tee $STDOUT

if (( ${PIPESTATUS[0]} ))
then
  echo "workflow.sh: swift-t exited with error!"
  exit 1
fi

echo "JOB OK" | tee -a $STDOUT
