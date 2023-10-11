
# LANGS APP mbook

echo "langs-app-mbook ..."

PY=/opt/homebrew/anaconda3/envs/tensorflow/

PATH=$PY/bin:$PATH


export PYTHONHOME=$PY
PYTHON="$PYTHONHOME/bin/"
export LD_LIBRARY_PATH="$PYTHONHOME/lib"
# export PATH="$PYTHONHOME/bin:$PATH"

COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH+=":$PYTHONHOME/lib/:"
PYTHONPATH+=":$COMMON_DIR:"

APP_PYTHONPATH=${APP_PYTHONPATH:-}
PYTHONPATH+=":$APP_PYTHONPATH"

export PYTHONPATH

echo "langs-app-mbook done."
