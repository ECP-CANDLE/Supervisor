
# ENV Summit

# SWIFT_IMPL=echo
SWIFT_IMPL=py

# Let modules initialize LD_LIBRARY_PATH before changing it:
set +eu # modules create errors outside our control
module load spectrum-mpi/10.3.1.2-20200121
module unload darshan-runtime
# module load ibm-wml-ce/1.6.2-3
module list
set -eu

# From Wozniak
MED106=/gpfs/alpine/world-shared/med106
ROOT=$MED106/sw/gcc-8.3.1
SWIFT=$ROOT/swift-t/2021-10-06

export TURBINE_HOME=$SWIFT/turbine
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

R=/gpfs/alpine/world-shared/med106/wozniak/sw/gcc-6.4.0/R-3.6.1/lib64/R
LD_LIBRARY_PATH+=:$R/lib

# PY=/gpfs/alpine/world-shared/med106/sw/condaenv-200408
# PY=/sw/summit/open-ce/anaconda-base/envs/open-ce-1.2.0-py38-0
PY=/gpfs/alpine/world-shared/med106/sw/conda/2021-10-06/envs/CANDLE-2021-10-06
LD_LIBRARY_PATH+=:$PY/lib
export PYTHONHOME=$PY
PATH=$PY/bin:$PATH

# /gpfs/alpine/world-shared/med106/sw/condaenv-200408
export LD_LIBRARY_PATH=$PY/lib:$LD_LIBRARY_PATH

# EMEWS Queues for R
EQR=$MED106/wozniak/sw/gcc-6.4.0/EQ-R
EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py

# For test output processing:
LOCAL=0
CRAY=1

# Resident task worker count and rank list
# If this is already set, we respect the user settings
# If this is unset, we set it to 1
#    and run the algorithm on the 2nd highest rank
# This value is only read in HPO workflows
if [[ ${TURBINE_RESIDENT_WORK_WORKERS:-} == "" ]]
then
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi
