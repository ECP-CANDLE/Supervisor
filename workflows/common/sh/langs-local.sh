
# LANGS LOCAL
# Language settings for any local machine like Ubuntu
# Assumes WORKFLOWS_ROOT, BENCHMARK_DIR, BENCHMARKS_ROOT are set

export PY=/usr/lib/python2.7/
# Modify to specify the location of SWIFT_T installation
export SWIFT_T=$HOME/install/
export LD_LIBRARY_PATH=$SWIFT_T/stc/lib:$SWIFT_T/turbine/lib/:$SWIFT_T/lb/lib:$SWIFT_T/cutils/lib

# Python
export PYTHONPATH=${PYTHONPATH:-}${PYTHONPATH:+:}
PYTHONPATH+=$WORKFLOWS_ROOT/common/python:

export PATH=$SWIFT_T/stc/bin:$PATH
SWIFT_IMPL="app"

# EMEWS Queues for R
EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R
# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}${LD_LIBRARY_PATH:+:}
# LD_LIBRARY_PATH+=$R_HOME/lib

# For test output processing:
LOCAL=1
CRAY=0

# Log settings to output
which python swift-t
# Cf. utils.sh
log_path LD_LIBRARY_PATH
log_path PYTHONPATH
