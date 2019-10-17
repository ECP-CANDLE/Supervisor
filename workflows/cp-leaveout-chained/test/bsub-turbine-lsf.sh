#!/bin/bash -l

# We use  to change the M4 comment to 
# Copyright 2013 University of Chicago and Argonne National Laboratory
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# TURBINE-LSF.SH.M4
# The Turbine LSF template.  This is automatically filled in
# by M4 in turbine-lsf-run.zsh

# Created: 2019-10-15 17:11:33


#BSUB -P MED106
#BSUB -J JOB:X048
#BSUB -nnodes 4
#BSUB -W 00:10
#BSUB -e /gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X048/output.txt
#BSUB -o /gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X048/output.txt
#BSUB -cwd /gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X048

# User directives:
# BEGIN TURBINE_DIRECTIVE

# END TURBINE_DIRECTIVE

set -eu

VERBOSE=0
if (( ${VERBOSE} ))
then
 set -x
fi

echo "TURBINE-LSF"
echo "TURBINE: DATE START: $( date "+%Y-%m-%d %H:%M:%S" )"
echo

TURBINE_OUTPUT=/gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X048

cd ${TURBINE_OUTPUT}

TURBINE_HOME=/gpfs/alpine/world-shared/med106/sw/gcc-7.4.0/swift-t/2019-10-15/turbine
COMMAND="/gpfs/alpine/world-shared/med106/sw/gcc-7.4.0/tcl-8.6.6/bin/tclsh8.6 /gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X048/workflow.tic -expid=X048 -benchmark_timeout=3600 -f=upf_test.txt"
PROCS=4
PPN=1

typeset -a USER_ENV_ARRAY
USER_ENV_ARRAY=( LD_LIBRARY_PATH '/autofs/nccs-svm1_sw/summit/.swci/1-compute/opt/spack/20180914/linux-rhel7-ppc64le/gcc-7.4.0/spectrum-mpi-10.3.0.1-20190611-mto4jwjeylfm6xdlb5yhaphpgnyzcvh7/lib:/sw/summit/gcc/7.4.0/lib64:/opt/ibm/spectrumcomputing/lsf/10.1/linux3.10-glibc2.17-ppc64le-csm/lib' BENCHMARKS_ROOT '/autofs/nccs-svm1_proj/med106/ncollier/repos/Benchmarks' EMEWS_PROJECT_ROOT '/autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/cp-leaveout-chained' MODEL_SH '/autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/common/sh/model.sh' SITE 'summit' BENCHMARK_TIMEOUT '3600' MODEL_NAME 'model' OBJ_RETURN 'val_loss' MODEL_PYTHON_SCRIPT '' MODEL_PYTHON_DIR '' APP_PYTHONPATH ':/autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/cp-leaveout-chained/py:/autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/common/python:/autofs/nccs-svm1_proj/med106/ncollier/repos/Benchmarks/Pilot1/Uno:/autofs/nccs-svm1_proj/med106/ncollier/repos/Benchmarks/common' PYTHONPATH '/sw/summit/xalt/1.1.4/site:/sw/summit/xalt/1.1.4/libexec:/autofs/nccs-svm1_proj/med106/ncollier/repos/Benchmarks/Pilot1/Uno:/autofs/nccs-svm1_proj/med106/ncollier/repos/Benchmarks/common:/gpfs/alpine/world-shared/med106/sw/gcc-7.4.0/swift-t/2019-10-15/turbine/py:/autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/cp-leaveout-chained/py:/autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/common/python' PYTHONHOME '/gpfs/alpine/world-shared/med106/sw/gcc-7.4.0/Python-3.5.1' TURBINE_OUTPUT '/gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X048'  )

# Construct jsrun-formatted user environment variable arguments
# The dummy is needed for old GNU bash (4.2.46, Summit) under set -eu
USER_ENV_ARGS=( -E _dummy=x )
COUNT=${#USER_ENV_ARRAY[@]}
for (( i=0 ; $i < $COUNT ; i+=2 ))
do
  i1=$(( $i + 1 ))
  USER_ENV_ARGS+=( -E ${USER_ENV_ARRAY[$i]}="${USER_ENV_ARRAY[$i1]}" )
done

# Restore user PYTHONPATH if the system overwrote it:
export PYTHONPATH=/gpfs/alpine/world-shared/med106/sw/gcc-7.4.0/swift-t/2019-10-15/turbine/py:/sw/summit/xalt/1.1.4/site:/sw/summit/xalt/1.1.4/libexec:/autofs/nccs-svm1_proj/med106/ncollier/repos/Benchmarks/Pilot1/Uno:/autofs/nccs-svm1_proj/med106/ncollier/repos/Benchmarks/common:/gpfs/alpine/world-shared/med106/sw/gcc-7.4.0/swift-t/2019-10-15/turbine/py:/autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/cp-leaveout-chained/py:/autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/common/python

export LD_LIBRARY_PATH=/autofs/nccs-svm1_sw/summit/.swci/1-compute/opt/spack/20180914/linux-rhel7-ppc64le/gcc-7.4.0/spectrum-mpi-10.3.0.1-20190611-mto4jwjeylfm6xdlb5yhaphpgnyzcvh7/lib:/sw/summit/gcc/7.4.0/lib64:/opt/ibm/spectrumcomputing/lsf/10.1/linux3.10-glibc2.17-ppc64le-csm/lib:
source ${TURBINE_HOME}/scripts/turbine-config.sh

# User prelaunch commands:
# For Summit use:
# module load gcc/6.3.1-20170301
# module load spectrum-mpi # /10.1.0.4-20170915
# # PATH=/opt/ibm/spectrum_mpi/jsm_pmix/bin:$PATH

# BEGIN TURBINE_PRELAUNCH

# END TURBINE_PRELAUNCH

TURBINE_LAUNCH_OPTIONS=( -n $PROCS -a1 -c42 -g1 )

START=$( date +%s.%N )
if (
   set -x
   jsrun ${TURBINE_LAUNCH_OPTIONS[@]} \
            -E TCLLIBPATH \
            -E ADLB_PRINT_TIME=1 \
            "${USER_ENV_ARGS[@]}" \
            ${COMMAND}
)
then
    CODE=0
else
    CODE=$?
    echo
    echo "TURBINE-LSF: jsrun returned an error code!"
    echo
fi
echo
echo "TURBINE: EXIT CODE: $CODE"
STOP=$( date +%s.%N )

# Bash cannot do floating point arithmetic:
DURATION=$( awk -v START=${START} -v STOP=${STOP} \
            'BEGIN { printf "%.3f\n", STOP-START }' < /dev/null )

echo
echo "TURBINE: MPIEXEC TIME: ${DURATION}"
echo "TURBINE: DATE STOP:  $( date "+%Y-%m-%d %H:%M:%S" )"
exit $CODE
