#!/bin/bash -l
set -eu

# JOB SH

echo $( basename $0 )
hostname

source /opt/modules/default/init/bash
module load modules
PATH=/opt/cray/elogin/eproxy/2.0.14-4.3/bin:$PATH # For aprun
module load alps

set -x
aprun -n 1 -N 1 $THIS/run-nt3.sh
