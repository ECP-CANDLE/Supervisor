
# ENV Lambda
# Environment settings for Lambdas 1-6 - not 7, 11, 12
# Note that Lambda7 is on a different FS and has its own scripts
# Lambdas 11 & 12 have a different OS
# (Swift, Python, R, Tcl, etc.)

# Everything is installed in here:
SFW=/homes/woz/Public/sfw

SWIFT=$SFW/swift-t/2022-11-02
PY=$SFW/Anaconda
# EQPY=$SFW/EQ-Py
EQR=$SFW/EQ-R
R=$SFW/R-4.1.0

PATH=$SWIFT/stc/bin:$PATH
PATH=$PY/bin:$PATH

# We only need this for R (including if Swift/T was compiled with R):
export LD_LIBRARY_PATH=$R/lib/R/lib:${LD_LIBRARY_PATH:-}

# How to run CANDLE models:
CANDLE_MODEL_IMPL="app"

# PYTHONPATH=$EQPY/src:${PYTHONPATH:-}

# Log settings to output
echo "Programs:"
which python swift-t | nl
# Cf. utils.sh
show     PYTHONHOME
log_path LD_LIBRARY_PATH
