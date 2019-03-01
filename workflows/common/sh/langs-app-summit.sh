# LANGS APP SUMMIT SH

# WIP 2019-02-28

APP_PYTHONPATH=${APP_PYTHONPATH:-$PYTHONPATH}

# Clear anything set by the system or Swift/T environment
unset PYTHONPATH
unset LD_LIBRARY_PATH

export PY=/gpfs/alpine/world-shared/med106/miniconda3
export LD_LIBRARY_PATH=/sw/summit/cuda/9.2.148/lib64:/sw/summit/gcc/6.4.0/lib64:$PY/lib
export PYTHONHOME=/gpfs/alpine/world-shared/med106/miniconda3
export PATH=$PYTHONHOME/bin:$PATH
export PYTHONPATH=$PYTHONHOME/lib/python3.6:$PYTHONHOME/lib/python3.6/site-packages:$APP_PYTHONPATH

