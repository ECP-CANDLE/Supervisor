#! /usr/bin/env bash
set -eu

# CP1 WORKFLOW
# Main entry point for CP1 workflow
# See README.md for more information

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

XCORR_DEFAULT=$( cd $EMEWS_PROJECT_ROOT/../xcorr ; /bin/pwd)
export XCORR_ROOT=${XCORR_ROOT:-$XCORR_DEFAULT}

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
export APP_PYTHONPATH=$BENCHMARK_DIR:$BENCHMARKS_ROOT/common:$XCORR_ROOT

START=$(( PROCS - TURBINE_RESIDENT_WORK_WORKERS - 1 ))
END=$(( START + TURBINE_RESIDENT_WORK_WORKERS - 1 ))
export RESIDENT_WORK_RANKS=$(seq -s , $START 1 $END )

echo "TURBINE_RESIDENT_WORK_WORKERS: $TURBINE_RESIDENT_WORK_WORKERS"
echo "RESIDENT_WORK_RANKS: $RESIDENT_WORK_RANKS"

if [[ ${EQR:-} == "" ]]
then
  abort "The site '$SITE' did not set the location of EQ/R: this will not work!"
fi

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

R_FILE_ARG=""
if [[ ${R_FILE:-} == "" ]]
then
  R_FILE="mlrMBO1.R"
fi

R_FILE_ARG="--r_file=$R_FILE"

if [ -z ${GPU_STRING+x} ];
then
  GPU_ARG=""
else
  GPU_ARG="-gpus=$GPU_STRING"
fi


mkdir -pv $TURBINE_OUTPUT

DB_FILE=$TURBINE_OUTPUT/cp1.db
if [[ ! -f DB_FILE ]]
then
  cp -v $EMEWS_PROJECT_ROOT/data/initial.db $TURBINE_OUTPUT/cp1.db
fi

CMD_LINE_ARGS=( -param_set_file=$PARAM_SET_FILE
                -mb=$MAX_BUDGET
                -ds=$DESIGN_SIZE
                -pp=$PROPOSE_POINTS
                -it=$MAX_ITERATIONS
                -exp_id=$EXPID
                -benchmark_timeout=$BENCHMARK_TIMEOUT
                -site=$SITE
                -db_file=$DB_FILE
                $GPU_ARG
                -cache_dir=$CACHE_DIR
                -xcorr_data_dir=$XCORR_DATA_DIR
                -rna_seq_data=$RNA_SEQ_DATA
                -drug_response_data=$DRUG_REPSONSE_DATA
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
mkdir -pv $TURBINE_OUTPUT/data
mkdir -pv $CACHE_DIR
mkdir -pv $XCORR_DATA_DIR
mkdir -pv $TURBINE_OUTPUT/hpo_log

# Allow the user to set an objective function
OBJ_DIR=${OBJ_DIR:-$WORKFLOWS_ROOT/common/swift}
OBJ_MODULE=${OBJ_MODULE:-model_$CANDLE_MODEL_IMPL}
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

#echo ${CMD_LINE_ARGS[@]}

swift-t -n $PROCS \
        ${MACHINE:-} \
        -p -I $EQR -r $EQR \
        -I $OBJ_DIR \
        -i $OBJ_MODULE \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
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
        -e PREPROP_RNASEQ \
        $WAIT_ARG \
        $EMEWS_PROJECT_ROOT/swift/$WORKFLOW_SWIFT ${CMD_LINE_ARGS[@]}
