#!/bin/bash -l

# From: https://github.com/brettin/Benchmarks/blob/ff/Pilot1/Uno/uno_baseline_keras2_qsub.sh

echo
echo TEMPLATE THETA

set -e

date "+%Y/%m/%d %H:%M:%S"

CONDA_ENV=py3.6_tf1.4

export PATH=/soft/datascience/conda/miniconda3/default/bin:$PATH

source activate ~/conda-envs/horovod # $CONDA_ENV

module load darshan
module load alps

set -u

export KMP_BLOCKTIME=0
export KMP_SETTINGS=0
export KMP_AFFINITY="granularity=fine,compact,1,0"
export OMP_NUM_THREADS=16
export NUM_INTER_THREADS=1
export NUM_INTRA_THREADS=16

cache=$( hostname )
cache=$COBALT_JOBID"_"$cache

PROGRAM=test.py

set -x

which python

unset HYDI_CONTROL_FD MPIR_CVAR_CH3_INTERFACE_HOSTNAME PMI_FD PMI_RANK PMI_SIZE

aprun -N 1 -n 1 -cc none -b python $PROGRAM \
      --epochs 5 \
      --cache 217024_thetamom3_cache \
      -v -l log.$COBALT_JOBID \
      --use_landmark_genes

set +x
source deactivate
