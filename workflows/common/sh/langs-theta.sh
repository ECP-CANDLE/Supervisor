# LANGS Theta
# Language settings for Theta (Swift, Python, R, Tcl, etc.)

TCL=/home/wozniak/Public/sfw/theta/tcl-8.6.1
export R=/home/wozniak/Public/sfw/theta/R-3.4.0/lib64/R
export PY=/home/wozniak/Public/sfw/theta/Python-2.7.12
export LD_LIBRARY_PATH=$PY/lib:$R/lib:$LD_LIBRARY_PATH
COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH=$EMEWS_PROJECT_ROOT/python:$BENCHMARK_DIR:$COMMON_DIR
PYTHONHOME=/home/wozniak/Public/sfw/theta/Python-2.7.12

# STC=/home/wozniak/Public/sfw/theta/swift-t-pyr/stc
STC=/projects/Candle_ECP/swift/pyr/stc

export PATH=$STC/bin:$TCL/bin:$PATH
