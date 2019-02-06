#!/bin/bash
set -eu

if [[ ${#} != 1 ]]
then
  echo "Specify a Swift script!"
  exit 1
fi
SCRIPT=$1

GCC=/opt/gcc/6.3.0/snos/lib64
R=/ccs/proj/med106/gounley1/titan/R-3.2.1/lib64/R/lib
LLP=$GCC:$R

SWIFT=/lustre/atlas2/med106/world-shared/sfw/titan/compute/swift-t/2018-12-12/stc/bin/swift-t

export PROJECT=med106
export QUEUE=debug
export TITAN=true
export PPN=2
PROCS=4

$SWIFT -m cray -n $PROCS \
       -e LD_LIBRARY_PATH=$LLP \
       $SCRIPT
