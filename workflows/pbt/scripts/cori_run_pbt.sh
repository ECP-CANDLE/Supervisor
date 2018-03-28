#! /usr/bin/env bash
set -eu

if [ "$#" -ne 3 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} MODEL_NAME EXPERIMENT_ID PARAMS_FILE"
  exit 1
fi

EXP_ID=$2
MODEL_NAME=$1
PARAMS=$3

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
ROOT="$THIS/.."
EXP_DIR="$ROOT/experiments/$EXP_ID"
PBT_PY="$ROOT/python/pbt.py"
PARAMS_FILE="$ROOT/data/$PARAMS"

SUPERVISOR=$( cd "$PWD/../../.."  ; /bin/pwd )
BENCHMARKS="$SUPERVISOR/../Benchmarks"

mkdir -p $EXP_DIR/weights
cp pbt.sbatch $EXP_DIR
cp "$(readlink -f $0)" $EXP_DIR

EXPORTS="ROOT=$ROOT,MODEL_NAME=$MODEL_NAME,PBT_PY=$PBT_PY,BENCHMARKS=$BENCHMARKS"
EXPORTS+=",SUPERVISOR=$SUPERVISOR,EXP_ID=$EXP_ID,PARAMS_FILE=$PARAMS_FILE,EXP_DIR=$EXP_DIR"

cd $EXP_DIR
#$PBT_FILE $PARAMS_FILE $EXP_DIR $MODEL_NAME $EXP_ID
sbatch --export=$EXPORTS \
      --job-name=$EXP_ID pbt.sbatch

cd $THIS
