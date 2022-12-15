
# ENV SUMMIT LOGIN
# Environment settings for Summit login node (Swift, Python, R, Tcl, etc.)

SWIFT_IMPL=echo
# SWIFT_IMPL=app
# SWIFT_IMPL=py

# Load basic LD_LIBRARY_PATH before changing it:
# module load gcc/7.4.0
module load gcc/6.4.0
# module load ibm-wml
module unload darshan-runtime
module unload spectrum-mpi
# module load gcc/7.4.0
module load gcc/6.4.0

module list

log_path PATH

# From Wozniak
MED106=/gpfs/alpine/world-shared/med106
# SWIFT=$MED106/sw/login/gcc-7.4.0/swift-t/2019-10-22    # Python (ibm-wml), no R
SWIFT=$MED106/wozniak/sw/login/gcc-6.4.0/swift-t/2020-10-22 # (opence010env)
# MPICH=$MED106/sw/login/gcc-7.4.0/mpich-3.2.1/bin
MPICH=$MED106/sw/login/gcc-6.4.0/mpich-3.2.1
PATH=$SWIFT/stc/bin:$PATH
PATH=$MPICH/bin:$PATH

# log_path PATH

# We do not export PYTHONPATH or PYTHONHOME
# We pass them through swift-t -e, which exports them later
# This is to avoid misconfiguring Python on the login node
PY=/sw/summit/ibm-wml/anaconda-powerai-1.6.1
PYTHONHOME=$PY
PYTHONPATH=${PYTHONPATH:-}${PYTHONPATH:+:}${SWIFT}/turbine/py

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PY/lib

# PATH=$PY/bin:$PATH

# EMEWS Queues for R
EQR=$MED106/EQ-R-190822
EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py

# For test output processing:
LOCAL=0
CRAY=1

# Resident task workers and ranks
if [[ ${TURBINE_RESIDENT_WORK_WORKERS:-} == "" ]]
then
    # Resident task workers and ranks
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi
