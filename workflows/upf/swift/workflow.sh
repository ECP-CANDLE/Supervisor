#! /usr/bin/env bash
set -eu

# UPF WORKFLOW SH

# Autodetect this workflow directory
export EMEWS_PROJECT_ROOT=$( readlink --canonicalize $( dirname $0 )/.. )
export WORKFLOWS_ROOT=$(     readlink --canonicalize $EMEWS_PROJECT_ROOT/..  )
export BENCHMARKS_ROOT=$(    readlink --canonicalize $EMEWS_PROJECT_ROOT/../../../Benchmarks.tf2 )

BENCHMARKS_DIR_BASE=$BENCHMARKS_ROOT/Pilot1/NT3:$BENCHMARKS_ROOT/Pilot2/P2B1:$BENCHMARKS_ROOT/Pilot1/P1B1:$BENCHMARKS_ROOT/Pilot1/Combo:$BENCHMARKS_ROOT/Pilot3/P3B1:$BENCHMARKS_ROOT/Pilot3/P3B3:$BENCHMARKS_ROOT/Pilot3/P3B4:$BENCHMARKS_ROOT/Pilot3/P3B5
export BENCHMARK_DIR=${BENCHMARK_DIR:-$BENCHMARKS_DIR_BASE}
SCRIPT_NAME=$(basename $0)

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh

export TURBINE_LOG=0 TURBINE_DEBUG=0 ADLB_DEBUG=0

usage()
{
  echo "UNROLLED PARAMETER FILE: usage: workflow.sh SITE EXPID CFG_SYS UPF"
}

if (( ${#} != 4 ))
then
  usage
  exit 1
fi

if ! {
  get_site    $1 # Sets SITE
  get_expid   $2 # Sets EXPID, TURBINE_OUTPUT
  get_cfg_sys $3
  UPF=$4
 }
then
  usage
  exit 1
fi

# Set PYTHONPATH for BENCHMARK related stuff
PYTHONPATH+=:$BENCHMARK_DIR:$BENCHMARKS_ROOT/common
PYTHONPATH+=:$WORKFLOWS_ROOT/common/python

source_site env   $SITE
source_site sched   $SITE

log_path PYTHONPATH

if [[ ${EQR:-} == "" ]]
then
  abort "The site '$SITE' did not set the location of EQ/R: this will not work!"
fi

export TURBINE_JOBNAME="JOB:${EXPID}"

OBJ_PARAM_ARG=""
if [[ ${OBJ_PARAM:-} != "" ]]
then
  OBJ_PARAM_ARG="--obj_param=$OBJ_PARAM"
fi

# Andrew: Allows for custom model.sh if desired
export MODEL_SH=${MODEL_SH:-$WORKFLOWS_ROOT/common/sh/model.sh}
export BENCHMARK_TIMEOUT

CMD_LINE_ARGS=( -expid=$EXPID
                -benchmark_timeout=$BENCHMARK_TIMEOUT
                -f=$UPF # ALW: keeping it as $UPF to allow $UPF to be a full path
                #-f=$TURBINE_OUTPUT/$UPF # Copied to TURBINE_OUTPUT below
              )

USER_VARS=( $CMD_LINE_ARGS )
# log variables and script to to TURBINE_OUTPUT directory
log_script

# Copy settings to TURBINE_OUTPUT for provenance
cp $CFG_SYS $TURBINE_OUTPUT

# Make run directory in advance to reduce contention
mkdir -pv $TURBINE_OUTPUT/run

which mpicc
which swift-t

module list

cp -v $UPF $TURBINE_OUTPUT

site2=$(echo $SITE | awk -v FS="-" '{print $1}') # ALW 2020-11-15: allow $SITEs to have hyphens in them as Justin implemented for Summit on 2020-10-29, e.g., summit-tf1

# ALW 2020-11-15: If we're running the candle wrapper scripts in which
# case if this file were being called then $CANDLE_RUN_WORKFLOW=1,
# don't set $TURBINE_LAUNCH_OPTIONS as this variable and the settings
# in the declaration below are handled by the wrapper scripts
if [[ ${site2} == "summit" && ${CANDLE_RUN_WORKFLOW:-0} != 1 ]]
then
  export TURBINE_LAUNCH_OPTIONS="-r6 -a1 -g1 -c7"
fi

TURBINE_STDOUT="$TURBINE_OUTPUT/out-%%r.txt"

swift-t -n $PROCS \
        -o $TURBINE_OUTPUT/workflow.tic \
        ${MACHINE:-} \
        -p -I $EQR -r $EQR \
        -I $WORKFLOWS_ROOT/common/swift \
        -i obj_$SWIFT_IMPL \
        -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
        -e BENCHMARKS_ROOT \
        -e EMEWS_PROJECT_ROOT \
        -e MODEL_SH \
        -e SITE \
        -e BENCHMARK_TIMEOUT \
        -e MODEL_NAME \
        -e OBJ_RETURN \
        -e MODEL_PYTHON_SCRIPT=${MODEL_PYTHON_SCRIPT:-} \
        -e TURBINE_MPI_THREAD=${TURBINE_MPI_THREAD:-1} \
        $( python_envs ) \
        -e TURBINE_STDOUT=$TURBINE_STDOUT \
        -e TURBINE_OUTPUT=$TURBINE_OUTPUT \
        -e PYTHONUNBUFFERED=1 \
        $EMEWS_PROJECT_ROOT/swift/workflow.swift ${CMD_LINE_ARGS[@]}

#        -e PYTHONVERBOSE=1
#         -e PATH=$PATH
