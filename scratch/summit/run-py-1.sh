#!/bin/sh
set -eu

ROOT=/ccs/home/wozniak/scratch-med106/proj
export BENCHMARKS_ROOT=$ROOT/Benchmarks
export SUPERVISOR_ROOT=$ROOT/SV.issue-61

m4 -P py-1.lsf.m4 > py-1.lsf

bsub py-1.lsf
