
# LANGS APP CORI
# Language settings for Cori app functions (Python, R, etc.)

# Uncomment this if want to run with tensorflow loaded from:
# module load tensorflow/intel-head. See 
# http://www.nersc.gov/users/data-analytics/data-analytics-2/deep-learning/using-tensorflow-at-nersc/
 
module swap craype-haswell craype-mic-knl
module load tensorflow/intel-head 
# # module load tensorflow/intel-head sets these:
# #setenv		 KMP_BLOCKTIME 1 
# #setenv		 KMP_SETTINGS 1 
# #setenv		 KMP_AFFINITY granularity=fine,verbose,compact,1,0 
# #setenv		 NUM_INTER_THREADS 2 
# #setenv		 NUM_INTRA_THREADS 16 
# #setenv		 OMP_NUM_THREADS 16 

# Cori / Tensorflow env vars
export KMP_BLOCKTIME=1
export KMP_SETTINGS=1
export KMP_AFFINITY="granularity=fine,verbose,compact,1,0"
export OMP_NUM_THREADS=68
export NUM_INTER_THREADS=1
export NUM_INTRA_THREADS=68

 
export PYTHONHOME="/usr/common/software/tensorflow/intel-tensorflow/head"
PYTHON="$PYTHONHOME/bin/python"
export LD_LIBRARY_PATH="$PYTHONHOME/lib"
export PATH="$PYTHONHOME/bin:$PATH"
 
COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH+=":$PYTHONHOME/lib/python2.7:"
PYTHONPATH+=":$COMMON_DIR:"
PYTHONPATH+="$PYTHONHOME/lib/python2.7/site-packages"
export PYTHONPATH
