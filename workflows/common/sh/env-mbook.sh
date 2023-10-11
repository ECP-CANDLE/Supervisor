
# ENV mbook
# Environment settings for mbook (Swift, Python, R, Tcl, etc.)

# Everything is installed in here:
SFW=/Users/mbook/install/

SWIFT=$SFW/swift-t/
PY=/opt/homebrew/anaconda3/envs/tensorflow/
# EQPY=$SFW/EQ-Py
EQR=/Users/mbook/Supervisor/workflows/common/ext/EQ-R/

PATH=$SWIFT/stc/bin:$PATH
PATH=$PY/bin:$PATH

export LD_LIBRARY_PATH=/Library/Frameworks/R.framework/Resources/lib/:${LD_LIBRARY_PATH:-}

# How to run CANDLE models:
CANDLE_MODEL_IMPL="app"

# PYTHONPATH=$EQPY/src:${PYTHONPATH:-}

# Log settings to output
echo "Programs:"
which python swift-t | nl
# Cf. utils.sh
show     PYTHONHOME

###
export PYTHONHOME=$PY

PYTHON="$PYTHONHOME/bin/"
export LD_LIBRARY_PATH="$PYTHONHOME/lib"
export PATH="$PYTHONHOME/bin:$PATH"

COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH+=":$PYTHONHOME/lib/:"
PYTHONPATH+=":$COMMON_DIR:"

APP_PYTHONPATH=${APP_PYTHONPATH:-}
PYTHONPATH+=":$APP_PYTHONPATH"
###

log_path LD_LIBRARY_PATH
