
# LANGS APP THETA SH

# Theta / Tensorflow env vars
export KMP_BLOCKTIME=30
export KMP_SETTINGS=1
export KMP_AFFINITY=granularity=fine,verbose,compact,1,0
export OMP_NUM_THREADS=128
export NUM_INTER_THREADS=1
export NUM_INTRA_THREADS=128

# export PYTHONHOME="/lus/theta-fs
APP_PYTHONPATH=${APP_PYTHONPATH:-$PYTHONPATH}

unset PYTHONPATH
unset LD_LIBRARY_PATH

module load datascience/keras-2.2.2
export PYTHONHOME="/opt/intel/python/2017.0.035/intelpython35"

APP_PYTHONPATH=${APP_PYTHONPATH:-$PYTHONPATH}
PYTHONPATH+=":/lus/theta-fs0/projects/CSC249ADOA01/hsyoo/candle_py_deps/"


PYTHON="$PYTHONHOME/bin/python"
export LD_LIBRARY_PATH="$PYTHONHOME/lib"
export PATH="$PYTHONHOME/bin:$PATH"

COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH+=":$PYTHONHOME/lib/python3.5:"
PYTHONPATH+=":$COMMON_DIR:"
PYTHONPATH+="$PYTHONHOME/lib/python3.5/site-packages:$APP_PYTHONPATH"
echo "APP PYTHONPATH: $PYTHONPATH"
export PYTHONPATH
