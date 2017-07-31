
# LANGS Titan
# Language settings for Titan (Swift, Python, R, Tcl, etc.)

TCL=/sw/xk6/tcl_tk/8.5.8/sles11.1_gnu4.5.3
export R=/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3x/lib64/R
export PY=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3
export LD_LIBRARY_PATH=$PY/lib:$R/lib:$LD_LIBRARY_PATH
COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python

# We do not export PYTHONPATH or PYTHONHOME
# We pass them through swift-t -e, which exports them later
# This is to avoid misconfiguring Python on the login node
# (especially for Cobalt)
PYTHONPATH=$EMEWS_PROJECT_ROOT/python:$BENCHMARK_DIR:$COMMON_DIR
PYTHONHOME=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3

export PATH=/lustre/atlas2/csc249/proj-shared/sfw/swift-t/stc/bin:$PATH
export PATH=$TCL/bin:$PATH
