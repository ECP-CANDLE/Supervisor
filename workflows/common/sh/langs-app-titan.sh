# export KMP_BLOCKTIME=30
# export KMP_SETTINGS=1
# export KMP_AFFINITY=granularity=fine,verbose,compact,1,0
# export OMP_NUM_THREADS=128

export PYTHONHOME="/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/"
PYTHON="$PYTHONHOME/bin/python"
#export LD_LIBRARY_PATH="$PYTHONHOME/lib"
export LD_LIBRARY_PATH=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/lib:/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/cuda/lib64:/opt/gcc/4.9.3/snos/lib64:/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3x/lib64/R/lib

export PATH="$PYTHONHOME/bin:$PATH"

BENCHMARK_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/common:$EMEWS_PROJECT_ROOT/../../../Benchmarks/Pilot1/P1B1
COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH="$PYTHONHOME/lib/python2.7:"
PYTHONPATH+="$BENCHMARK_DIR:$COMMON_DIR:"
PYTHONPATH+="$PYTHONHOME/lib/python2.7/site-packages"
export PYTHONPATH
