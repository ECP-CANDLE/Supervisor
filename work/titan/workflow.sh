#!/bin/bash
set -eu

LD_LIBRARY_PATH=/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3x/lib64/R/lib:/opt/java/jdk1.8.0_51/jre/lib/amd64/server:/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3/lib64/R/lib:/sw/xk6/curl/7.30.0/sles11.1_gnu4.3.4/lib:/opt/gcc/4.9.3/snos/lib64

SWIFT=/lustre/atlas2/csc249/proj-shared/sfw/swift-t/stc/bin/swift-t

export PROJECT=CSC249ADOA01
export QUEUE=debug
export TITAN=true
export PPN=2
PROCS=4

$SWIFT -m cray -n $PROCS \
       -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
       workflow.swift
