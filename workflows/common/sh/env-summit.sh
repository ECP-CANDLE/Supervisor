
# ENV Summit
# Environment settings for Summit (Swift, Python, R, Tcl, etc.)

SWIFT_IMPL=app

# Load basic LD_LIBRARY_PATH before changing it:
module load spectrum-mpi

ROOT=/gpfs/alpine/world-shared/med106

export PY=$ROOT/miniconda3
export R=$ROOT/gcc-6.4.0/R-3.5.2/lib64/R/lib

export LD_LIBRARY_PATH=$R:$LD_LIBRARY_PATH

SWIFT=$ROOT/gcc-6.4.0/swift-t/2019-02-27
PATH=$SWIFT/stc/bin:$PATH

log_path PATH

# We do not export PYTHONPATH or PYTHONHOME
# We pass them through swift-t -e, which exports them later
# This is to avoid misconfiguring Python on the login node
# (especially for Cobalt)
PYTHONHOME=$PY

# EMEWS Queues for R
EQR=$ROOT/gcc-6.4.0/EQ-R
EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py

# For test output processing:
LOCAL=0
CRAY=1

# Resident task workers and ranks
if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]
then
    # Resident task workers and ranks
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi

# log_path PYTHONPATH
