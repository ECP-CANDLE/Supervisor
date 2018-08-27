
# LANGS CORI
# Language settings for Singularity Biowulf (Python, R, etc.)
# Assumes WORKFLOWS_ROOT is set

# Swift/T
#SWIFT=/global/homes/w/wozniak/Public/sfw/compute/swift-t-2018-06-05
#export PATH=$SWIFT/stc/bin:$PATH
# On Cori, we have a good Swift/T Python embedded interpreter,
# but we use app anyway
SWIFT_IMPL="app"

# Python
#PYTHON=/global/common/cori/software/python/2.7-anaconda/envs/deeplearning
#export PATH=$PYTHON/bin:$PATH
PYTHON=$(which python)
export PYTHONPATH=${PYTHONPATH:-}${PYTHONPATH:+:}
PYTHONPATH+=$EMEWS_PROJECT_ROOT/python:
PYTHONPATH+=$BENCHMARK_DIR:
PYTHONPATH+=$BENCHMARKS_ROOT/common:
#PYTHONPATH+=$SWIFT/turbine/py:
COMMON_DIR=$WORKFLOWS_ROOT/common/python
PYTHONPATH+=$COMMON_DIR
export PYTHONHOME=$PYTHON

# R
#export R_HOME=/global/homes/w/wozniak/Public/sfw/R-3.4.0-gcc-7.1.0/lib64/R

# EMEWS Queues for R
#EQR=/global/homes/w/wozniak/Public/sfw/compute/EQ-R
EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py
# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
echo "RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS"

# LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}${LD_LIBRARY_PATH:+:}
#LD_LIBRARY_PATH+=$R_HOME/lib

# Log settings to output
which python swift-t
# Cf. utils.sh
# show     PYTHONHOME
# log_path LD_LIBRARY_PATH
# log_path PYTHONPATH
