# export KMP_BLOCKTIME=30
# export KMP_SETTINGS=1
# export KMP_AFFINITY=granularity=fine,verbose,compact,1,0
# export OMP_NUM_THREADS=128

export PYTHONHOME="/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/"
PYTHON="$PYTHONHOME/bin/python"
#export LD_LIBRARY_PATH="$PYTHONHOME/lib"
export LD_LIBRARY_PATH=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/lib:/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/cuda/lib64:/opt/gcc/4.9.3/snos/lib64

export PATH="$PYTHONHOME/bin:$PATH"

COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH+=":$PYTHONHOME/lib/python2.7:"
PYTHONPATH+="$COMMON_DIR:"
PYTHONPATH+="$PYTHONHOME/lib/python2.7/site-packages"
export PYTHONPATH
