# LANGS THETA
# Language settings for Theta (Python, R, etc.)
# Assumes WORKFLOWS_ROOT is set
# Assumes modules are loaded (cf. modules-cori.sh)

# Python

TCL=/home/wozniak/Public/sfw/theta/tcl-8.6.1
export R=/home/wozniak/Public/sfw/theta/R-3.4.0/lib64/R
export PY=/home/wozniak/Public/sfw/theta/Python-2.7.12
export LD_LIBRARY_PATH=$PY/lib:$R/lib:$LD_LIBRARY_PATH
COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH=$EMEWS_PROJECT_ROOT/python:$BENCHMARK_DIR:$COMMON_DIR
PYTHONHOME=/home/wozniak/Public/sfw/theta/Python-2.7.12

export PATH=/home/wozniak/Public/sfw/theta/swift-t-pyr/stc/bin:$TCL/bin:$PATH
