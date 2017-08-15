
# LANGS Theta
# Language settings for Theta (Swift, Python, R, Tcl, etc.)

# TCL=/home/wozniak/Public/sfw/theta/tcl-8.6.1
# export R=/home/wozniak/Public/sfw/theta/R-3.4.0/lib64/R
# export PY=/home/wozniak/Public/sfw/theta/Python-2.7.12

# STC=/home/wozniak/Public/sfw/theta/swift-t-pyr/stc
# STC=/projects/Candle_ECP/swift/pyr/stc
STC=/projects/Candle_ECP/swift/2017-08-11/stc

export TCL=/projects/Candle_ECP/swift/deps/tcl-8.6.6
export PY=/projects/Candle_ECP/swift/deps/Python-2.7.12
export R=/projects/Candle_ECP/swift/deps/R-3.4.1/lib64/R

export LD_LIBRARY_PATH=$PY/lib:$R/lib:$LD_LIBRARY_PATH
COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH=$EMEWS_PROJECT_ROOT/python:$BENCHMARK_DIR:$COMMON_DIR
PYTHONHOME=$PY

export PATH=$STC/bin:$TCL/bin:$PY/bin:$PATH

# EMEWS Queues for R
EQR=/home/wozniak/Public/sfw/theta/EQ-R
# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# The Swift Implementation type: "app" or "py"
# Selects the *.swift files to include
# If "app", use app functions
# If "py", use in-memory Python functions
SWIFT_IMPL="app"

# Log settings to output
echo "Programs:"
which python swift-t | nl
# Cf. utils.sh
show     PYTHONHOME
log_path LD_LIBRARY_PATH
log_path PYTHONPATH
