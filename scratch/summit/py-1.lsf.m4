#!/bin/bash -l

m4_changecom(`dnl')
m4_define(`m4_getenv', `m4_esyscmd(printf -- "$`$1'")')

#BSUB -P MED106
#BSUB -J CANDLE
#BSUB -nnodes 1
#BSUB -W 00:05
#BSUB -cwd m4_getenv(PWD)

echo "LSF"
echo "DATE START: $( date "+%Y-%m-%d %H:%M" )"
echo

BENCHMARKS_ROOT=m4_getenv(BENCHMARKS_ROOT)
SUPERVISOR_ROOT=m4_getenv(SUPERVISOR_ROOT)

jsrun -n 1 -g 1 -a 1 \
      --env SUPERVISOR_ROOT=$SUPERVISOR_ROOT \
      --env BENCHMARKS_ROOT=$BENCHMARKS_ROOT \
      ./model.sh

echo "DATE STOP:  $( date "+%Y-%m-%d %H:%M" )"
