
# LANGS APP LAMBDA 1X

echo "langs-app-lambda-1X ..."

SFW=/homes/woz/Public/sfw

PY=$SFW/Miniconda-2023-09-18

PATH=$PY/bin:$PATH

export CONDA_PREFIX=$PY

source $PY/etc/profile.d/conda.sh
source $PY/etc/conda/activate.d/env_vars.sh

# Magic from https://github.com/google/jax/issues/4920
export XLA_PYTHON_CLIENT_PREALLOCATE="false"
export XLA_PYTHON_CLIENT_ALLOCATOR="platform"
export TF_FORCE_GPU_ALLOW_GROWTH="true"

echo "langs-app-lambda-1X done."
