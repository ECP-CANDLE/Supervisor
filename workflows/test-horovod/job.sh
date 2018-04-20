#!/bin/bash -l
#COBALT -n 4
#COBALT -q debug-flat-quad
#COBALT -A CSC249ADOA01
#COBALT -t 00:03:00
#COBALT -o output.txt
#COBALT -e output.txt

# # COBALT -q default

echo
echo
echo JOB.SH START

date "+%Y/%m/%d %H:%M:%S"
echo

# Works
source ./template-theta.sh

set -x

# Works
./template-theta.sh

# Works
bash ./template-theta.sh

# Fails
MPIEXEC=/home/wozniak/Public/sfw/theta/mpich-3.2/bin/mpiexec
$MPIEXEC ./template-theta.sh

echo JOB.SH END
