
# LANGS APP THETA SH

# Theta / Tensorflow env vars
export KMP_BLOCKTIME=0
export KMP_SETTINGS=1
export KMP_AFFINITY=granularity=fine,verbose,compact,1,0
export OMP_NUM_THREADS=128
export NUM_INTER_THREADS=1
export NUM_INTRA_THREADS=128

APP_PYTHONPATH=${APP_PYTHONPATH:-$PYTHONPATH}

# Clear anything set by the system or Swift/T environment
unset PYTHONPATH
unset LD_LIBRARY_PATH

module load datascience/tensorflow-1.14
module load datascience/keras-2.2.4
export PYTHONHOME=/soft/interpreters/python/3.6/intel/2019.3.075/

PYTHONPATH=$PYTHONPATH:/soft/interpreters/python/3.6/intel/2019.3.075/lib/python3.6/site-packages/:/projects/CSC249ADOA01/hsyoo/candle_py36_deps/lib/python3.6/site-packages/:$APP_PYTHONPATH

echo "APP_PYTHONPATH: $APP_PYTHONPATH"
echo "PYTHONPATH: $PYTHONPATH"
echo "PYTHONHOME: $PYTHONHOME"
export PYTHONPATH
