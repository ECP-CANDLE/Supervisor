#!/bin/bash
set -eu

# WORKFLOW.SH

# SIMPLE UQ WORKFLOW
# Main entry point
# See README.md for more information

echo "WORKFLOW: SIMPLE UQ"

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
BENCHMARKS_ROOT=$( cd $EMEWS_PROJECT_ROOT/../../../Benchmarks ; /bin/pwd)
BENCHMARK_DIR=$BENCHMARKS_ROOT/Pilot1/P1B1
SCRIPT_NAME=$(basename $0)

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

usage()
{
  echo "UQ: usage: workflow.sh SITE EXPID CFG_SYS CFG_PRM"
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

# #Set PYTHONPATH for BENCHMARK related stuff
# BENCHMARK_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/common:$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot1/P1B1
# PYTHONPATH+=":$BENCHMARK_DIR:"

export TURBINE_JOBNAME="JOB:${EXPID}"

CMD_LINE_ARGS=(
  -exp_id=$EXPID
  -benchmark_timeout=${BENCHMARK_TIMEOUT:-NONE}
  -site=$SITE
)

WORKFLOW_SWIFT=
swift-t -n $PROCS \
        $MACHINE  \
        -p -l -o workflow.tic -U $EMEWS_PROJECT_ROOT/swift/obj_app.swift \
        -I $EMEWS_PROJECT_ROOT/swift \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e TURBINE_RESIDENT_WORK_WORKERS=$TURBINE_RESIDENT_WORK_WORKERS \
        -e RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS \
        -e EMEWS_PROJECT_ROOT=$EMEWS_PROJECT_ROOT \
        $( python_envs ) \
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        $EMEWS_PROJECT_ROOT/swift/workflow.swift ${CMD_LINE_ARGS[@]}


#        -i obj_$SWIFT_IMPL
#        -i log_$SWIFT_IMPL
