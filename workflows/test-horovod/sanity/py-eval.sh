#!/bin/bash -l

SV=$HOME/proj/SV
PY_EVAL=$SV/scratch/py-eval
PATH=$PY_EVAL:$PATH

module load gcc
module load tensorflow/intel-head

which python
echo PP  $PYTHONPATH
echo PUB $PYTHONUSERBASE

py-eval $*
