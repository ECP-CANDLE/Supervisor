
# LANGS LOCAL
# Language settings for any local machine like Ubuntu
# Assumes WORKFLOWS_ROOT, BENCHMARK_DIR, BENCHMARKS_ROOT are set

export PY=/homes/jain/anaconda3/bin/python/
export R=/home/wozniak/Public/sfw/x86_64/R-3.4.1/lib/R/
# Modify to specify the location of SWIFT_T installation
export SWIFT_T=${SWIFT_T:-/homes/jain/install/swift-t/}
export LD_LIBRARY_PATH+=:$R/lib:$SWIFT_T/stc/lib:$SWIFT_T/turbine/lib/:$SWIFT_T/lb/lib:$SWIFT_T/cutils/lib

# Python
export PYTHONPATH=${PYTHONPATH:-}${PYTHONPATH:+:}
PYTHONPATH+=$WORKFLOWS_ROOT/common/python:

export PATH=$SWIFT_T/turbine/bin:$SWIFT_T/stc/bin:$PATH
echo $PATH
SWIFT_IMPL="py"

# EMEWS Queues for R
EQR=$WORKFLOWS_ROOT/common/ext/EQ-R
EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py
# Resident task workers and ranks
if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]
then
    # Resident task workers and ranks
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi


# LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}${LD_LIBRARY_PATH:+:}

# For test output processing:
export LOCAL=1
export CRAY=0

# Cf. utils.s
log_path LD_LIBRARY_PATH
log_path PYTHONPATH
