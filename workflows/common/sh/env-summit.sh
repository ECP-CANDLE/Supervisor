
# ENV Summit
# Environment settings for Summit (Swift, Python, R, Tcl, etc.)

SWIFT_IMPL=app

# Load basic LD_LIBRARY_PATH before changing it:
module load gcc/4.8.5
module load spectrum-mpi/10.3.0.1-20190611

ROOT=/ccs/proj/med106/gounley1/summit

export PY=$ROOT/miniconda3
export R=$ROOT/R-190814/lib64/R/lib

export LD_LIBRARY_PATH=$R:$LD_LIBRARY_PATH

SWIFT=$ROOT/swift-t-190814
PATH=$SWIFT/stc/bin:$PATH

# log_path PATH

# We do not export PYTHONPATH or PYTHONHOME
# We pass them through swift-t -e, which exports them later
# This is to avoid misconfiguring Python on the login node
PYTHONHOME=$PY
PYTHONPATH=${PYTHONPATH:-}${PYTHONPATH:+:}${SWIFT}/turbine/py

# EMEWS Queues for R
EQR=$ROOT/EQ-R-190814
EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py

# For test output processing:
LOCAL=0
CRAY=1

export TURBINE_LAUNCH_OPTIONS="-g6 -c42 -a1"

# Resident task workers and ranks
if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]
then
    # Resident task workers and ranks
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi

# log_path PYTHONPATH
