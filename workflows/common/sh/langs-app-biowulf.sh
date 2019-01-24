
# LANGS APP Singularity on Biowulf
# Language settings for singularity app functions (Python, R, etc.)

module load python/3.6

COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
#PYTHONPATH+=":$PYTHONHOME/lib/python2.7:"
PYTHONPATH+=":$COMMON_DIR:"
#PYTHONPATH+="$PYTHONHOME/lib/python2.7/site-packages"
export PYTHONPATH
