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
export BENCHMARKS_ROOT=$( cd $EMEWS_PROJECT_ROOT/../../../Benchmarks ; /bin/pwd)
BENCHMARKS_DIR_BASE=$BENCHMARKS_ROOT/Pilot1/TC1:$BENCHMARKS_ROOT/Pilot1/NT3:$BENCHMARKS_ROOT/Pilot1/P1B1:$BENCHMARKS_ROOT/Pilot1/Combo:$BENCHMARKS_ROOT/Pilot2/P2B1
export BENCHMARK_TIMEOUT
export BENCHMARK_DIR=${BENCHMARK_DIR:-$BENCHMARKS_DIR_BASE}

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
source_site sched   $SITE

# Set PYTHONPATH for BENCHMARK related stuff
EQPY=${EQPY:-$WORKFLOWS_ROOT/common/ext/EQ-Py}
PYTHONPATH+=:$BENCHMARK_DIR:$BENCHMARKS_ROOT/common:$EQPY


PYTHONPATH+=:$WORKFLOWS_ROOT/common/python/

export TURBINE_JOBNAME="JOB:${EXPID}"
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

# echo's anything following this to standard out

swift-t -n $PROCS \
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
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        -e OBJ_RETURN \
        -e MODEL_PYTHON_SCRIPT=${MODEL_PYTHON_SCRIPT:-} \
        -e MODEL_SH \
        -e MODEL_NAME \
        -e SITE \
        -e BENCHMARK_TIMEOUT \
        -e SH_TIMEOUT \
        -e IGNORE_ERRORS \
        $WAIT_ARG \
        $EMEWS_PROJECT_ROOT/swift/workflow.swift ${CMD_LINE_ARGS[@]}
        
