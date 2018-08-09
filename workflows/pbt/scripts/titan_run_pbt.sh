#! /usr/bin/env bash
set -eu

if [ "$#" -ne 2 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} EXPERIMENT_ID PARAMS_FILE"
  exit 1
fi

export EXP_ID=$1
PARAMS_FILE=$2

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
ROOT="$THIS/.."

source titan.cfg

export EXP_DIR=${EXP_DIR:-"$ROOT/experiments/$EXP_ID"}
PBT_PY="$ROOT/python/tc1_pbt.py"

SUPERVISOR=$( cd "$PWD/../../.."  ; /bin/pwd )
BENCHMARKS="$SUPERVISOR/../Benchmarks"

mkdir -p $EXP_DIR/weights

export NODES=$(( PROCS/PPN ))
(( PROCS % PPN )) && (( NODES++ )) || true
declare NODES

SH=$EXP_DIR/run.pbs
m4 common.m4 titan.pbs.m4 > ${SH}
chmod u+x ${SH}
cp -p $PARAMS_FILE $EXP_DIR
cp "$(readlink -f $0)" $EXP_DIR

P_FILE="./$(basename $PARAMS_FILE)"

EXPORTS="ROOT=$ROOT,PBT_PY=$PBT_PY,BENCHMARKS=$BENCHMARKS"
EXPORTS+=",SUPERVISOR=$SUPERVISOR,EXP_ID=$EXP_ID,PARAMS_FILE=$P_FILE,EXP_DIR=$EXP_DIR"

echo "EXPERIMENT DIRECTORY: $EXP_DIR"

cd $EXP_DIR
#$PBT_FILE $PARAMS_FILE $EXP_DIR $MODEL_NAME $EXP_ID
CMD="qsub -v $EXPORTS -d $EXP_DIR -N $EXP_ID $SH"
echo $CMD
$CMD

cd $THIS
