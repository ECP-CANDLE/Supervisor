# Theta / Tensorflow env vars
export KMP_BLOCKTIME=30
export KMP_SETTINGS=1
export KMP_AFFINITY=granularity=fine,verbose,compact,1,0
export OMP_NUM_THREADS=128

export PYTHONHOME="/lus/theta-fs0/projects/Candle_ECP/ncollier/py2_tf_gcc6.3_eigen3_native"
PYTHON="$PYTHONHOME/bin/python"
export LD_LIBRARY_PATH="$PYTHONHOME/lib"
export PATH="$PYTHONHOME/bin:$PATH"

BENCHMARK_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/common:$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot1/P1B1
COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH="$PYTHONHOME/lib/python2.7:"
PYTHONPATH+="$BENCHMARK_DIR:$COMMON_DIR:"
PYTHONPATH+="$PYTHONHOME/lib/python2.7/site-packages"
export PYTHONPATH
