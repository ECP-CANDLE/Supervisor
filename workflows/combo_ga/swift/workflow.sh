#! /usr/bin/env bash
set -eu

# COMBO WORKFLOW
# Main entry point for COMBO mlrMBO workflow
# See README.md for more information

echo "WORKFLOW: COMBO"

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
export WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
export BENCHMARKS_ROOT=$( cd $EMEWS_PROJECT_ROOT/../../../Benchmarks ; /bin/pwd)
export BENCHMARK_DIR=$BENCHMARKS_ROOT/Pilot1/Combo
SCRIPT_NAME=$(basename $0)

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

#source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh" - moved to utils.sh

# uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1

usage()
{
  echo "COMBO: usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM"
}

if (( ${#} != 4 ))
then
  usage
  exit 1
fi

if ! {
  get_site    $1 # Sets SITE
  get_expid   $2 # Sets EXPID
  get_cfg_sys $3
  get_cfg_prm $4
 }
then
  usage
  exit 1
fi

source_site modules $SITE
source_site langs   $SITE
source_site sched   $SITE

# Set PYTHONPATH for BENCHMARK related stuff
PYTHONPATH+=:$BENCHMARK_DIR:$BENCHMARKS_ROOT/common:$EQPY:$HOME/.local/cori/deeplearning2.7/lib/python2.7/site-packages

if [[ ${EQPY:-} == "" ]]
then
  abort "The location of EQ/Py is not set: this will not work!"
fi

export TURBINE_JOBNAME="JOB:${EXPID}"

# RESTART_FILE_ARG=""
# if [[ ${RESTART_FILE:-} != "" ]]
# then
#   RESTART_FILE_ARG="--restart_file=$RESTART_FILE"
# fi
#
# RESTART_NUMBER_ARG=""
# if [[ ${RESTART_NUMBER:-} != "" ]]
# then
#   RESTART_NUMBER_ARG="--restart_number=$RESTART_NUMBER"
# fi

OBJ_PARAM_ARG=""
if [[ ${OBJ_PARAM:-} != "" ]]
then
  OBJ_PARAM_ARG="--obj_param=$OBJ_PARAM"
fi

CMD_LINE_ARGS=( -ga_params=$PARAM_SET_FILE
                -init_params=$INIT_PARAMS_FILE
                -seed=$SEED
                -ni=$NUM_ITERATIONS
                -nv=$NUM_VARIATIONS
                -np=$POPULATION_SIZE
                -strategy=$GA_STRATEGY
                -model_sh=$EMEWS_PROJECT_ROOT/scripts/run_model.sh
                -model_name=$MODEL_NAME
                -exp_id=$EXPID
                -benchmark_timeout=$BENCHMARK_TIMEOUT
                -site=$SITE
                $OBJ_PARAM_ARG
              )

USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

#Store scripts to provenance
#copy the configuration files to TURBINE_OUTPUT
cp $WORKFLOWS_ROOT/common/python/$GA_FILE $PARAM_SET_FILE $CFG_SYS $CFG_PRM $TURBINE_OUTPUT

# echo's anything following this to standard out
WORKFLOW_SWIFT=workflow.swift
swift-t -n $PROCS \
        ${MACHINE:-} \
        -p -I $EQPY -r $EQPY \
        -I $WORKFLOWS_ROOT/common/swift \
        -i obj_$SWIFT_IMPL \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
        -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
        -e BENCHMARKS_ROOT \
        -e EMEWS_PROJECT_ROOT \
        $( python_envs ) \
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        $EMEWS_PROJECT_ROOT/swift/workflow.swift ${CMD_LINE_ARGS[@]}
