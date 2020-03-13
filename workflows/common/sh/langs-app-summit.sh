# LANGS APP SUMMIT SH

# WIP 2019-02-28

APP_PYTHONPATH=${APP_PYTHONPATH:-$PYTHONPATH}

# Clear anything set by the system or Swift/T environment
unset PYTHONPATH
unset LD_LIBRARY_PATH

# ROOT=/ccs/proj/med106/gounley1/summit
ROOT=/gpfs/alpine/world-shared/med106/gounley1/sandbox2
export PY=$ROOT/.envs
export LD_LIBRARY_PATH=/sw/summit/cuda/10.1.243/lib64:/sw/summit/gcc/7.4.0/lib64:$PY/lib
export PYTHONHOME=$ROOT/.envs
export PATH=$PYTHONHOME/bin:$PATH
export PYTHONPATH=$PYTHONHOME/lib/python3.6:$PYTHONHOME/lib/python3.6/site-packages:$APP_PYTHONPATH
