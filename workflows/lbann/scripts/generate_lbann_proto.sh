#! /usr/bin/env bash
set -eu


#usage ./generate_lbann_proto.sh 8 lbann_lassen_exp2 mnist_params.json mnist
NUM_TRAINERS=$1 
EXP_ID=$2
PARAMS_FILE=$3
MODEL_NAME=$4

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
ROOT="$THIS/.."
EXP_DIR="$ROOT/experiments/$EXP_ID"

SUPERVISOR=$( cd "$PWD/../../.."  ; /bin/pwd )
LBANN_ROOT=/usr/workspace/wsa/jacobs32/git.samadejacobs.lbann

#export SPACK_ROOT=/usr/workspace/wsa/jacobs32/git.samadejacobs.lbann/build/spack; .$SPACK_ROOT/share/spack/setup-env.sh
export SPACK_ROOT=$LBANN_ROOT/build/spack; . $SPACK_ROOT/share/spack/setup-env.sh
spack env activate -p lbann-dev-power9le
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${cuDNN_ROOT}/lib"
#module use $LBANN_ROOT/build/spack.gnu.Release.lassen.llnl.gov/install/etc/modulefiles
module use $LBANN_ROOT/build/gnu.Release.lassen.llnl.gov/install/etc/modulefiles
module load lbann-0.102.0

#PYTHONPATH+=$SUPERVISOR/workflows/common/python
PYTHONPATH+=":$SUPERVISOR/workflows/common/python"
PYTHONPATH+=":$ROOT/models/mnist"
PYTHONPATH+=":$ROOT/models/atom"
#@todo add host_name
#PYTHONPATH+=":$LBANN_ROOT/build/spack.gnu.Release.lassen.llnl.gov/install/lib/python3.7/site-packages"
#PYTHONPATH+=":$LBANN_ROOT/build/gnu.Release.lassen.llnl.gov.atom/install/lib/python3.7/site-packages"
#PYTHONPATH+=":$LBANN_ROOT/build/gnu.Release.pascal.llnl.gov.atom/install/lib/python3.7/site-packages"

export PYTHONPATH=$PYTHONPATH
echo $PYTHONPATH
mkdir -p $EXP_DIR
LBANN_PY="$ROOT/python/generate_lbann_proto.py"

cp $ROOT/data/$PARAMS_FILE $EXP_DIR/
cd $EXP_DIR
NUM_TRAINERS=$((NUM_TRAINERS + 1))
CMD="mpirun -n $NUM_TRAINERS python3 -u $LBANN_PY $PARAMS_FILE $EXP_DIR $MODEL_NAME $EXP_ID"
#CMD="srun --export=ALL -n $NUM_TRAINERS python3 -u $LBANN_PY $PARAMS_FILE $EXP_DIR mnist $EXP_ID"
echo $CMD
$CMD
#cd $THIS
