#!/bin/bash -l
# Need -l to reset modules ...
set -eu

# SETUP NT3

echo $( basename $0 )
hostname

# Modules start
module unload cray-python/3.6.5.3
module load   datascience/tensorflow-1.14
module load   datascience/keras-2.2.4
# Modules end

# Report original source directory
echo THIS=$THIS

set -x
BENCHMARKS=$( readlink --canonicalize $THIS/../../../Benchmarks )
NT3=$BENCHMARKS/Pilot1/NT3/nt3_baseline_keras2.py

which python

set -x
python $NT3 --epochs 1
