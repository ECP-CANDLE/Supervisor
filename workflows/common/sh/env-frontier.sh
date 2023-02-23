
# ENV Frontier

# SWIFT_IMPL=echo
SWIFT_IMPL=py

# From Wozniak
# MED106=/gpfs/alpine/world-shared/med106
# ROOT=$MED106/sw/summit/gcc-7.5.0
ROOT=/autofs/nccs-svm1_home1/wozniak/Public/sfw/frontier
# SWIFT=$ROOT/swift-t/2022-07-25  # Works
SWIFT=$ROOT/swift-t/2023-02-23

export TURBINE_HOME=$SWIFT/turbine
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

# R=$ROOT/R/4.1.3/lib64/R
# LD_LIBRARY_PATH+=:$R/lib

PY=/gpfs/alpine/med106/proj-shared/hm0/candle_tf_2.10
# PY=/gpfs/alpine/world-shared/med106/sw/conda/2021-10-06/envs/CANDLE-2021-10-06
# PY=/sw/summit/open-ce/anaconda-base/envs/open-ce-1.5.2-py39-0
# PY=/gpfs/alpine/world-shared/med106/sw/open-ce-1.1.3-py37/
# # PY=/gpfs/alpine/world-shared/med106/sw/conda/m-39-2022-09-15
# LD_LIBRARY_PATH+=:$PY/lib
# export PYTHONHOME=$PY
PATH=$PY/bin:$PATH

# /gpfs/alpine/world-shared/med106/sw/condaenv-200408
# export LD_LIBRARY_PATH=$PY/lib:$LD_LIBRARY_PATH

# EMEWS Queues for R
# EQR=$ROOT/EQ-R

# EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py

# For test output processing:
LOCAL=0
CRAY=1
