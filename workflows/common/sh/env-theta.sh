
# LANGS Theta
# Language settings for Theta (Swift, Python, R, Tcl, etc.)

# TCL=/home/wozniak/Public/sfw/theta/tcl-8.6.1
# export R=/home/wozniak/Public/sfw/theta/R-3.4.0/lib64/R
# export PY=/home/wozniak/Public/sfw/theta/Python-2.7.12

# STC=/home/wozniak/Public/sfw/theta/swift-t-pyr/stc
# STC=/projects/Candle_ECP/swift/pyr/stc
# STC=/projects/Candle_ECP/swift/2017-12-20/stc
# SWIFT=/projects/Candle_ECP/swift/2018-03-07
SWIFT=/projects/Candle_ECP/swift/2019-02-27
# SWIFT=/projects/Candle_ECP/swift/2018-04-25

# This has:
# using Python: /lus/theta-fs0/projects/Candle_ECP/ncollier/py2_tf_gcc6.3_eigen3_native/lib python2.7
# using R: /projects/Candle_ECP/swift/deps/R-3.4.1/lib64/R
# SWIFT=/home/wozniak/Public/sfw/theta/swift-t/2018-08-22b

export TCL=/projects/Candle_ECP/swift/deps/tcl-8.6.6
export PY=/projects/Candle_ECP/swift/deps/Python-2.7.12
export R=/projects/Candle_ECP/swift/deps/R-3.4.1/lib64/R

# export LD_LIBRARY_PATH=$PY/lib:$R/lib:${LD_LIBRARY_PATH:-}
export LD_LIBRARY_PATH=$R/lib:${LD_LIBRARY_PATH:-}
COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH=$EMEWS_PROJECT_ROOT/python:$BENCHMARK_DIR:$COMMON_DIR:$SWIFT/turbine/py
PYTHONHOME=$PY

export PATH=$SWIFT/stc/bin:$TCL/bin:$PY/bin:$PATH

# EMEWS Queues for R
EQR=/home/wozniak/Public/sfw/theta/EQ-R
EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py
PYTHONPATH=$EQPy:$PYTHONPATH
# Resident task workers and ranks
if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]
then
    # Resident task workers and ranks
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi


# The Swift Implementation type: "app" or "py"
# Selects the *.swift files to include
# If "app", use app functions
# If "py", use in-memory Python functions
SWIFT_IMPL="app"

export TURBINE_LAUNCH_OPTIONS="-cc none"

# Log settings to output
echo "Programs:"
which python swift-t | nl
# Cf. utils.sh
show     PYTHONHOME
log_path LD_LIBRARY_PATH
log_path PYTHONPATH
