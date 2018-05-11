#!/bin/bash -l

SV=$HOME/proj/SV
PY_EVAL=$SV/scratch/py-eval
PATH=$PY_EVAL:$PATH

module load gcc
# module load tensorflow/intel-head
module load python/2.7-anaconda-4.4

which python
echo PP  $PYTHONPATH
echo PUB $PYTHONUSERBASE

py-eval $*
