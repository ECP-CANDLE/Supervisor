#!/bin/bash
set -eu

if [[ ${#} != 1 ]]
then
  echo "Specify a Swift script!"
  exit 1
fi
SCRIPT=$1

LD_LIBRARY_PATH=/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3x/lib64/R/lib:/opt/java/jdk1.8.0_51/jre/lib/amd64/server:/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3/lib64/R/lib:/sw/xk6/curl/7.30.0/sles11.1_gnu4.3.4/lib:/opt/gcc/6.3.0/snos/lib64

SWIFT=/lustre/atlas2/med106/world-shared/sfw/titan/compute/swift-t/2018-12-12/stc/bin/swift-t

export PROJECT=med106
export QUEUE=debug
export TITAN=true
export PPN=2
PROCS=4

$SWIFT -m cray -n $PROCS \
       -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
       $SCRIPT
