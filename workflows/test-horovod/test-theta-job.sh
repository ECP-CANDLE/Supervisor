#!/bin/bash -l
#COBALT -n 1
#COBALT -q debug-flat-quad
#COBALT -A CSC249ADOA01
#COBALT -t 00:03:00
#COBALT -o output.txt
#COBALT -e output.txt

# # COBALT -q default

# From: https://github.com/brettin/Benchmarks/blob/ff/Pilot1/Uno/uno_baseline_keras2_qsub.sh

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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $DIR

PROGRAM=test.py

# aprun -N 1 -cc none -b python $DIR/uno_baseline_keras2.py --cache $cache"_cache" -v -l log.0 --use_landmark_genes
aprun -N 1 -n 1 -cc none -b python test.py \
      --epochs 5 \
      --cache 217024_thetamom3_cache \
      -v -l log.$COBALT_JOBID \
      --use_landmark_genes

source deactivate
