
# ENV LOCAL
# Language settings for any local machine like Ubuntu
# Assumes WORKFLOWS_ROOT, BENCHMARK_DIR, BENCHMARKS_ROOT are set
# Modify to specify the location of SWIFT_T installation
export SWIFT_T=${SWIFT_T:-$HOME/install/swift-t/}
export LD_LIBRARY_PATH+=$SWIFT_T/turbine/lib:$SWIFT_T/lb/lib:$SWIFT_T/cutils/lib

# Python
export PYTHONPATH=${PYTHONPATH:-}${PYTHONPATH:+:}
PYTHONPATH+=$WORKFLOWS_ROOT/common/python:
PYTHONPATH+=$HOME/swift-work/lock-mgr/lib

export PATH=$SWIFT_T/stc/bin:$PATH
SWIFT_IMPL="app"

# EMEWS Queues for R
EQR=$WORKFLOWS_ROOT/common/ext/EQ-R
EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py

if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]
then
    # Resident task workers and ranks
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi

# LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}${LD_LIBRARY_PATH:+:}
# LD_LIBRARY_PATH+=$R_HOME/lib

# For test output processing:
export LOCAL=1
export CRAY=0

PATH=$SWIFT_T/bin/:$PATH
# Cf. utils.sh
log_path LD_LIBRARY_PATH
log_path PYTHONPATH
