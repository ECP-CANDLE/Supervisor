# LANGS APP SUMMIT SH

APP_PYTHONPATH=${APP_PYTHONPATH:-$PYTHONPATH}

# Clear anything set by the system or Swift/T environment
unset PYTHONPATH
unset LD_LIBRARY_PATH

export PY=/gpfs/alpine/world-shared/med106/sw/open-ce-1.1.3-py37/
export LD_LIBRARY_PATH=$PY/lib:$LD_LIBRARY_PATH
export PYTHONHOME=$PY
export PATH=$PYTHONHOME/bin:$PATH
export PYTHONPATH=$PYTHONHOME/lib/python3.9:$PYTHONHOME/lib/python3.9/site-packages:$APP_PYTHONPATH
