#! /usr/bin/env bash
set -eu

if [ "$#" -ne 2 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} EXPERIMENT_ID PARAMS_FILE"
  exit 1
fi

EXP_ID=$1
PARAMS_FILE=$2

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
ROOT="$THIS/.."
export EXP_DIR="$ROOT/experiments/$EXP_ID"
PBT_PY="$ROOT/python/tc1_pbt.py"

SUPERVISOR=$( cd "$PWD/../../.."  ; /bin/pwd )
BENCHMARKS="$SUPERVISOR/../Benchmarks"

mkdir -p $EXP_DIR/weights
source theta.cfg

THETA_SH=$EXP_DIR/theta.sh
m4 common.m4 theta.cobalt.m4 > ${THETA_SH}
chmod u+x ${THETA_SH}
cp -p $PARAMS_FILE $EXP_DIR
cp "$(readlink -f $0)" $EXP_DIR

P_FILE="./$(basename $PARAMS_FILE)"

EXPORTS="ROOT=$ROOT:PBT_PY=$PBT_PY:BENCHMARKS=$BENCHMARKS"
EXPORTS+=":SUPERVISOR=$SUPERVISOR:EXP_ID=$EXP_ID:PARAMS_FILE=$P_FILE:EXP_DIR=$EXP_DIR"

#cd $EXP_DIR
#$PBT_FILE $PARAMS_FILE $EXP_DIR $MODEL_NAME $EXP_ID
qsub --env $EXPORTS --jobname=$EXP_ID --mode script $THETA_SH

#cd $THIS
