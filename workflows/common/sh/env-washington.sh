
# LANGS WASHINGTON
# Language settings for Washington
# Assumes WORKFLOWS_ROOT, BENCHMARK_DIR, BENCHMARKS_ROOT are set

# Python
# PY=/vol/ml/hsyoo/anaconda3
PY=/home/wozniak/Public/sfw/anaconda3
export PYTHONPATH=${PYTHONPATH:-}${PYTHONPATH:+:}
PYTHONPATH+=$WORKFLOWS_ROOT/common/python:
PATH=$PY/bin:$PATH

# R
# export R_HOME=/home/wozniak/Public/sfw/R-3.4.1/lib/R
# export R_HOME=/home/wozniak/Public/sfw/R-3.4.3/lib/R
R=/homes/wozniak/Public/sfw/R-3.5.3
export R_HOME=$R/lib/R
PATH=$R/bin:$PATH

# Swift/T
export PATH=/homes/wozniak/Public/sfw/swift-t/2019-05-23/stc/bin:$PATH
# SWIFT_IMPL="app" # use this one for real runs
SWIFT_IMPL="echo"  # use this one to debug the model.sh command line

# EMEWS Queues for R
# EQR=/opt/EQ-R
EQR=/home/wozniak/Public/sfw/EQ-R

# Resident task workers and ranks
if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]
then
    # Resident task workers and ranks
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi

# LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}${LD_LIBRARY_PATH:+:}
LD_LIBRARY_PATH+=$R_HOME/lib

show LD_LIBRARY_PATH

# For test output processing:
LOCAL=1
CRAY=0

# Cf. utils.sh ...
which_check python
which_check R
which_check swift-t
swift-t -v
# Log settings to output
# show     PYTHONHOME
# log_path LD_LIBRARY_PATH
# log_path PYTHONPATH
