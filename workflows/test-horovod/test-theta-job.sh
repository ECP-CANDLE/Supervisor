#!/bin/bash -l
#COBALT -n 2
#COBALT -q debug-flat-quad
#COBALT -A CSC249ADOA01
#COBALT -t 00:03:00

# # COBALT -q default

set -x

CONDA_ENV=py3.6_tf1.4

source activate $CONDA_ENV
module load darshan

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

# aprun -N 1 -cc none -b python $DIR/uno_baseline_keras2.py --cache $cache"_cache" -v -l log.0 --use_landmark_genes
aprun -N 1 -n 2 -cc none -b python $DIR/uno_baseline_keras2_hvd.py \
      --epochs 5 \
      --cache 217024_thetamom3_cache \
      -v -l log.$COBALT_JOBID \
      --use_landmark_genes

source deactivate
