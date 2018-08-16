#!/bin/bash -l

# From: https://github.com/brettin/Benchmarks/blob/ff/Pilot1/Uno/uno_baseline_keras2_qsub.sh

echo
echo TEMPLATE THETA

set -e

date "+%Y/%m/%d %H:%M:%S"

CONDA_ENV=py3.6_tf1.4

export PATH=/soft/datascience/conda/miniconda3/default/bin:$PATH
BENCHMARKS=$HOME/proj/Benchmarks
export PYTHONPATH=$BENCHMARKS/common:$BENCHMARKS/Pilot1/Uno

echo PYTHONPATH: $PYTHONPATH

source activate ~/conda-envs/horovod # $CONDA_ENV

# module load darshan
module load alps

LD_LIBRARY_PATH+=:/soft/perftools/darshan/darshan-3.1.5/lib
LD_LIBRARY_PATH+=:$HOME/conda-envs/horovod/lib

echo "Running on $(hostname)"
# aprun -n 1 -N 1 --cc none /bin/hostname

set -u

export KMP_BLOCKTIME=0
export KMP_SETTINGS=0
export KMP_AFFINITY="granularity=fine,compact,1,0"
export OMP_NUM_THREADS=16
export NUM_INTER_THREADS=1
export NUM_INTRA_THREADS=16

# Need to add this shell's PID for uniqueness when doing multiple apruns
# under a Cobalt allocation
ID=${COBALT_JOBID:-LOCAL}_${$}

cache=$( hostname )
cache="${ID}_$cache"

# PROGRAM=test.py
PROGRAM=program.py

START=$SECONDS

set -x

which python

# unset HYDI_CONTROL_FD MPIR_CVAR_CH3_INTERFACE_HOSTNAME PMI_FD PMI_RANK PMI_SIZE

set +e

aprun -N 1 -n 1 -cc none -b \
      python -u $PROGRAM \
      --epochs 5 \
      --cache 217024_thetamom3_cache \
      -v -l log.$ID \
      --use_landmark_genes 2>&1 > task-${cache}.txt

set +x
set +u
STOP=$SECONDS

echo "aprun time: $(( STOP - START ))"
source deactivate
