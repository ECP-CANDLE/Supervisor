
# LANGS APP FRONTIER SH

# Allow for user PYTHONPATH additions:
APP_PYTHONPATH=${APP_PYTHONPATH:-}

# Overwrite anything else set by the system or Swift/T environment:
export PY=/gpfs/alpine/med106/proj-shared/hm0/candle_tf_frontier
export LD_LIBRARY_PATH=$PY/lib
export PYTHONHOME=$PY
export PATH=$PYTHONHOME/bin:$PATH
export PYTHONPATH=$PYTHONHOME/lib/python3.9:$PYTHONHOME/lib/python3.9/site-packages:$APP_PYTHONPATH
