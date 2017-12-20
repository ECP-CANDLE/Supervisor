
# LANGS CORI
# Language settings for Cori (Python, R, etc.)
# Assumes WORKFLOWS_ROOT is set
# Assumes modules are loaded (cf. modules-cori.sh)

# Python
COMMON_DIR=$WORKFLOWS_ROOT/common/python
export PYTHONPATH=${PYTHONPATH:-}${PYTHONPATH:+:}
PYTHONPATH+=$EMEWS_PROJECT_ROOT/python:
PYTHONPATH+=$BENCHMARK_DIR:
PYTHONPATH+=$BENCHMARKS_ROOT/common:
PYTHONPATH+=$COMMON_DIR
export PYTHONHOME=/global/common/cori/software/python/2.7-anaconda/envs/deeplearning

# R
export R_HOME=/global/u1/w/wozniak/Public/sfw/R-3.4.0/lib64/R

# Swift/T
export PATH=/global/homes/w/wozniak/Public/sfw/compute/swift-t-r/stc/bin:$PATH
# On Cori, we have a good Swift/T Python embedded interpreter
SWIFT_IMPL="app"

# EMEWS Queues for R
EQR=/global/homes/w/wozniak/Public/sfw/compute/EQ-R
# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}${LD_LIBRARY_PATH:+:}
LD_LIBRARY_PATH+=$R_HOME/lib

# Log settings to output
which python swift-t
# Cf. utils.sh
show     PYTHONHOME
log_path LD_LIBRARY_PATH
log_path PYTHONPATH
