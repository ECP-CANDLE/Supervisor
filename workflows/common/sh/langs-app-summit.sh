
# LANGS APP SUMMIT SH

# Allow for user PYTHONPATH additions:
APP_PYTHONPATH=${APP_PYTHONPATH:-}

# Overwrite anything else set by the system or Swift/T environment:
export PY=/gpfs/alpine/world-shared/med106/sw/open-ce-1.1.3-py37
export LD_LIBRARY_PATH=$PY/lib
export PYTHONHOME=$PY
export PATH=$PYTHONHOME/bin:$PATH
export PYTHONPATH=$PYTHONHOME/lib/python3.9:$PYTHONHOME/lib/python3.9/site-packages:$APP_PYTHONPATH
