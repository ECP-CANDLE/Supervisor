#!/bin/bash
#
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1

usage()
{
  echo "P1B1: usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM"
}

if (( ${#} != 4 ))
then
  usage
  exit 1
fi

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
export WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
export BENCHMARKS_ROOT=$( cd $EMEWS_PROJECT_ROOT/../../../Benchmarks ; /bin/pwd)
export BENCHMARK_DIR=$BENCHMARKS_ROOT/Pilot1/P1B1
SCRIPT_NAME=$(basename $0)
source $WORKFLOWS_ROOT/common/sh/utils.sh


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

# Set PYTHONPATH for BENCHMARK related stuff
PYTHONPATH+=:$BENCHMARK_DIR:$BENCHMARKS_ROOT/common

source_site env   $SITE
source_site sched   $SITE

export TURBINE_JOBNAME="JOB:${EXPID}"

CMD_LINE_ARGS=( -param_set_file=$PARAM_SET_FILE
                -mb=$MAX_BUDGET
                -ds=$DESIGN_SIZE
                -pp=$PROPOSE_POINTS
                -it=$MAX_ITERATIONS
                -model_sh=$EMEWS_PROJECT_ROOT/scripts/run_model.sh
                -model_name=$MODEL_NAME
                -exp_id=$EXPID
                -benchmark_timeout=$BENCHMARK_TIMEOUT
                -site=$SITE
		-settings=$EMEWS_PROJECT_ROOT/data/settings.json
                $RESTART_FILE_ARG
                $RESTART_NUMBER_ARG
                $LEARNER1_NAME_ARG
              )

# remove -l option for removing printing processors ranks
# settings.json file has all the parameter combinations to be tested

#echo swift-t -l  -n $PROCS $EMEWS_PROJECT_ROOT/random-sweep.swift $*
#swift-t  -l -n $PROCS $EMEWS_PROJECT_ROOT/random-sweep.swift $* --settings=$PWD/../data/settings.json



# Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=($CMD_LINE_ARGS "VAR_1" "VAR_2")
USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

# echo's anything following this to standard out

swift-t -n $PROCS \
        ${MACHINE:-} \
        -I $WORKFLOWS_ROOT/common/swift \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
        -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
        -e BENCHMARKS_ROOT \
        -e EMEWS_PROJECT_ROOT \
        $( python_envs ) \
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        $EMEWS_PROJECT_ROOT/swift/random-sweep.swift ${CMD_LINE_ARGS[@]}
