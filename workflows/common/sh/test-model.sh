#!/bin/bash
set -eu

# TEST MODEL RUNNER

usage()
{
  echo "test-model: usage: MODEL_NAME PARAMS"
  echo "test-model: PARAMS is a JSON fragment in 1 string"
  echo "test-model: edit this file to set the basic environment"
  echo "test-model: and PYTHONPATH"
  exit 1
}

THIS=$( readlink --canonicalize $( dirname $0 ) )

# Basic environment begin
export TURBINE_OUTPUT=${TURBINE_OUTPUT:-$THIS/output}
export SITE="dunedin"
export OBJ_RETURN="val_loss"
export BENCHMARK_TIMEOUT=-1
# Basic environment end

export WORKFLOWS_ROOT=$( readlink --canonicalize $PWD/../.. )
export BENCHMARKS_ROOT=$( readlink --canonicalize \
                                   $WORKFLOWS_ROOT/../../Benchmarks )
export PYTHONPATH=$BENCHMARKS_ROOT/Pilot1/Uno


if [[ ${#} != 2 ]]
then
  usage
  exit 1
fi

export MODEL_NAME=$1
PARAMS=$2

mkdir -pv $TURBINE_OUTPUT

set -x
bash $THIS/model.sh keras "$PARAMS" X000
