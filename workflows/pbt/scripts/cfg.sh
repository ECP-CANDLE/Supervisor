EXP_ID=$1

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
ROOT="$THIS/.."
EXP_DIR="$ROOT/experiments/$EXP_ID"

BENCHMARKS=$HOME/Documents/repos/Benchmarks
SUPERVISOR=$( cd "$PWD/../../.."  ; /bin/pwd )

PYTHONPATH=$BENCHMARKS/Pilot1/common
PYTHONPATH+=":$BENCHMARKS/common"
PYTHONPATH+=":$SUPERVISOR/workflows/common/python"
PYTHONPATH+=":$ROOT/models/tc1"

export PYTHONPATH=$PYTHONPATH

mkdir -p $EXP_DIR

PARAMS_PATH=$2
cp $PARAMS_PATH $EXP_DIR/
cd $EXP_DIR
