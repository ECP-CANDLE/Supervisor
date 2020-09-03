#! /usr/bin/env bash
set -eu

# UQ NOISE WORKFLOW
# Main entry point for UQ-NOISE workflow
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

XCORR_DEFAULT=$( cd $EMEWS_PROJECT_ROOT/../xcorr ; /bin/pwd)
export XCORR_ROOT=${XCORR_ROOT:-$XCORR_DEFAULT}

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

echo "Running "$MODEL_NAME "workflow"

source_site env   $SITE
source_site sched $SITE

# Set PYTHONPATH for BENCHMARK related stuff
PYTHONPATH+=:$BENCHMARK_DIR:$BENCHMARKS_ROOT/common:$XCORR_ROOT
PYTHONPATH+=:$WORKFLOWS_ROOT/common/python       # needed for model_runner and logs

export APP_PYTHONPATH=$BENCHMARK_DIR:$BENCHMARKS_ROOT/common:$XCORR_ROOT

export TURBINE_JOBNAME="JOB:${EXPID}"

if [ -z ${GPU_STRING+x} ];
then
  GPU_ARG=""
else
  GPU_ARG="-gpus=$GPU_STRING"
fi

mkdir -pv $TURBINE_OUTPUT

DB_FILE=$TURBINE_OUTPUT/uq-noise.db
if [[ ! -f DB_FILE ]]
then
  if [[ ${UQ_NOISE_ID:-} == "" ]]
  then
    if [[ ${EXPID:0:1} == "X" ]]
    then
      UQ_NOISE_ID=${EXPID:1}
    else
      UQ_NOISE_ID=$EXPID
    fi
  fi
  # $EMEWS_PROJECT_ROOT/db/db-cplo-init $DB_FILE $UQ_NOISE_ID
fi

CMD_LINE_ARGS=( -benchmark_timeout=$BENCHMARK_TIMEOUT
                -exp_id=$EXPID
                -site=$SITE
                -db_file=$DB_FILE
                $GPU_ARG
                -cache_dir=$CACHE_DIR
              )

USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

# Make run directory in advance to reduce contention
mkdir -pv $TURBINE_OUTPUT/run
mkdir -pv $TURBINE_OUTPUT/data
mkdir -pv $CACHE_DIR
mkdir -pv $XCORR_DATA_DIR
mkdir -pv $TURBINE_OUTPUT/hpo_log

# Allow the user to set an objective function
OBJ_DIR=${OBJ_DIR:-$WORKFLOWS_ROOT/common/swift}
SWIFT_IMPL="py"
OBJ_MODULE=${OBJ_MODULE:-obj_abstention_$SWIFT_IMPL}
# This is used by the obj_app objective function
export MODEL_SH=$WORKFLOWS_ROOT/common/sh/model_abstention.sh

# log_path PYTHONPATH

WORKFLOW_SWIFT=${WORKFLOW_SWIFT:-workflow-abstention.swift}
echo "WORKFLOW_SWIFT: $WORKFLOW_SWIFT"

WAIT_ARG=""
if (( ${WAIT:-0} ))
then
  WAIT_ARG="-t w"
  echo "Turbine will wait for job completion."
fi

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
  # use for summit (slurm needs two %)
  export TURBINE_STDOUT="$TURBINE_OUTPUT/out/out-%%r.txt"

  #export TURBINE_STDOUT="$TURBINE_OUTPUT/out/out-%r.txt"
  mkdir -pv $TURBINE_OUTPUT/out
  STDOUT=""
fi

#echo ${CMD_LINE_ARGS[@]}

cd $TURBINE_OUTPUT
cp $CFG_SYS $CFG_PRM $WORKFLOWS_ROOT/uq-noise/swift/workflow-noise.swift $TURBINE_OUTPUT

if [[ ${SITE} == "summit" ]]
then
  export TURBINE_LAUNCH_OPTIONS="-r6 -a1 -g1 -c7" 
fi
TURBINE_RESIDENT_WORK_WORKERS=1

swift-t -n $PROCS \
        ${MACHINE:-} \
        -p \
        -I $OBJ_DIR \
        -i $OBJ_MODULE \
        -e LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-} \
        -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
        -e TURBINE_STDOUT \
        -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
        -e BENCHMARKS_ROOT \
        -e EMEWS_PROJECT_ROOT \
        -e XCORR_ROOT \
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
        $WAIT_ARG \
        $EMEWS_PROJECT_ROOT/swift/$WORKFLOW_SWIFT ${CMD_LINE_ARGS[@]} |& \
  tee $STDOUT


if (( ${PIPESTATUS[0]} ))
then
  echo "workflow.sh: swift-t exited with error!"
  exit 1
fi

# echo "EXIT CODE: 0" | tee -a $STDOUT

