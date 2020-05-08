#!/bin/bash
set -eu

if [[ ${#} != 1 ]]
then
  echo "Specify a Swift script!"
  exit 1
fi
SCRIPT=$1

SWIFT=

module load spectrum-mpi/10.3.1.2-20200121

G=/sw/summit/gcc/6.4.0/lib64
R=""
LD_LIBRARY_PATH=$G:$R:$LD_LIBRARY_PATH

export PROJECT=MED106
# export QUEUE=debug
export PPN=2
PROCS=4

SWIFT=/gpfs/alpine/world-shared/med106/wozniak/sw/gcc-6.4.0/swift-t/2020-03-31-c/stc/bin/swift-t

set -x
$SWIFT -m lsf -n $PROCS \
       $SCRIPT
