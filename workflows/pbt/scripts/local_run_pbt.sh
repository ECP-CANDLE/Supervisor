#! /usr/bin/env bash
set -eu

PROCS=$1
EXP_ID=$2
#MODEL_NAME=$3

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
ROOT="$THIS/.."
EXP_DIR="$ROOT/experiments/$EXP_ID"
PBT_PY="$ROOT/python/tc1_pbt.py"

BENCHMARKS=$HOME/Documents/repos/Benchmarks
SUPERVISOR=$( cd "$PWD/../../.."  ; /bin/pwd )

PYTHONPATH=$BENCHMARKS/Pilot1/common
PYTHONPATH+=":$BENCHMARKS/common"
PYTHONPATH+=":$SUPERVISOR/workflows/common/python"
PYTHONPATH+=":$ROOT/models/tc1"

export PYTHONPATH=$PYTHONPATH

mkdir -p $EXP_DIR

PARAMS_FILE=$3
cp $ROOT/data/$PARAMS_FILE $EXP_DIR/
cd $EXP_DIR

mpirun -n $PROCS python $PBT_PY $PARAMS_FILE $EXP_DIR tc1 $EXP_ID

cd $THIS
