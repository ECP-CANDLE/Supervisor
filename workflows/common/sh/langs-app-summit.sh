# LANGS APP SUMMIT SH

# WIP 2019-02-28

APP_PYTHONPATH=${APP_PYTHONPATH:-$PYTHONPATH}

# Clear anything set by the system or Swift/T environment
unset PYTHONPATH
unset LD_LIBRARY_PATH

ROOT=/ccs/proj/med106/gounley1/summit
export PY=$ROOT/miniconda3
export LD_LIBRARY_PATH=/sw/summit/cuda/10.1.168/lib64:/sw/summit/gcc/4.8.5/lib64:$PY/lib
export PYTHONHOME=$ROOT/miniconda3
export PATH=$PYTHONHOME/bin:$PATH
export PYTHONPATH=$PYTHONHOME/lib/python3.7:$PYTHONHOME/lib/python3.7/site-packages:$APP_PYTHONPATH

