#! /usr/bin/env bash
set -eu

if [ "$#" -ne 3 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} SITE EXPERIMENT_ID PARAMS_FILE"
  exit 1
fi

SITE=$1
export EXP_ID=$2
PARAMS_FILE=$3

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
export ROOT="$THIS/.."

# get output directory, nodes, etc.
source $SITE.cfg

export EXP_DIR=${EXP_DIR:-$ROOT/experiments/$EXP_ID}
export PBT_PY="$ROOT/python/p3b3_pbt.py"

export SUPERVISOR=$( cd "$PWD/../../.."  ; /bin/pwd )
export BENCHMARKS="$SUPERVISOR/../Benchmarks"

# python path common to all sites (PP)
PP+=":$BENCHMARKS/common"
PP+=":$SUPERVISOR/workflows/common/python"
PP+=":$ROOT/models/p3b3"
export PP=$PP

mkdir -p "$EXP_DIR/weights"

export NODES=$(( PROCS/PPN ))
(( PROCS % PPN )) && (( NODES++ )) || true
declare NODES

SH=$EXP_DIR/script.sh
m4 common.m4 "$SITE"_submit.m4 > ${SH}
chmod u+x ${SH}
cp -p $PARAMS_FILE $EXP_DIR
cp "$(readlink -f $0)" $EXP_DIR

export P_FILE="./$(basename $PARAMS_FILE)"
export PARAMS_FILE="$PARAMS_FILE"

echo "EXPERIMENT DIRECTORY: $EXP_DIR"

source "$SITE"_submit.cfg
CMD="bsub $SH"

#echo $CMD
$CMD

