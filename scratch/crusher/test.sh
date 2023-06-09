#!/bin/bash -l
set -eu

if (( ${#} != 1 ))
then
  echo "Provide the workflow!"
  exit 1
fi

WORKFLOW=$1

MED106=/gpfs/alpine/world-shared/med106
SWIFT=/gpfs/alpine/world-shared/med106/gounley1/crusher2/swift-t-install

PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

PY=/gpfs/alpine/world-shared/med106/gounley1/crusher2/conda520

which swift-t

export PROJECT=MED106_crusher
export QUEUE=batch
export WALLTIME=00:05:00
export PROCS=2
export PPN=2

export TURBINE_LAUNCHER=srun

set -x
swift-t -m slurm -n $PROCS -e PYTHONHOME=$PY $WORKFLOW
