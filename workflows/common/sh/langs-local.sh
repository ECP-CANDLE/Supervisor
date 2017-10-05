
# LANGS LOCAL
# Language settings for any local machine like Ubuntu
# Assumes WORKFLOWS_ROOT, BENCHMARK_DIR, BENCHMARKS_ROOT are set

# TODO: Rename to langs-jain.sh
# TODO: Merge LD_LIBRARY_PATH sections

export PY=/usr/lib/python2.7/
# export PATH=$PATH
export LD_LIBRARY_PATH=/home/jain/install/mpich-3.2/lib:/home/jain/install/jasper/lib:/home/jain/install/netcdf/lib:/home/jain/install/hdf5/lib:/home/jain/install/stc/lib:/home/jain/install/turbine/lib/:/home/jain/install/lb/lib:/home/jain/install/cutils/lib

# Python
export PYTHONPATH=${PYTHONPATH:-}${PYTHONPATH:+:}
PYTHONPATH+=$WORKFLOWS_ROOT/common/python:

# R
#export R_HOME=

# Swift/T
export PATH=$HOME/install/stc/bin:$PATH
SWIFT_IMPL="app"

# EMEWS Queues for R
EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R
# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}${LD_LIBRARY_PATH:+:}
# LD_LIBRARY_PATH+=$R_HOME/lib

# Log settings to output
which python swift-t
# Cf. utils.sh
log_path LD_LIBRARY_PATH
log_path PYTHONPATH
