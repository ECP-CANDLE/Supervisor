
# LANGS APP Biowulf
# Language settings for app functions (Python, R, etc.)

# Load the environment in which CANDLE was built
module load "$CANDLE_DEFAULT_PYTHON_MODULE"

#module load openmpi/3.1.2/cuda-9.0/gcc-7.3.0-pmi2 cuDNN/7.1/CUDA-9.0 CUDA/9.0
#source /data/$USER/conda/etc/profile.d/conda.sh
#conda activate kds-tf1.12.2 # /data/weismanal/conda/envs/kds-tf1.12.2/bin/python / /usr/local/Anaconda/envs/py3.6/bin/python

COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
#PYTHONPATH+=":$PYTHONHOME/lib/python2.7:"
PYTHONPATH+=":$COMMON_DIR:"
#PYTHONPATH+="$PYTHONHOME/lib/python2.7/site-packages"
export PYTHONPATH
