
# LANGS APP LAMBDA

echo "langs-app-lambda ..."

SFW=/home/woz/Public/sfw

PY=$SFW/Anaconda

PATH=$PY/bin:$PATH

echo "Programs:"
which python

PYTHONPATH=${APP_PYTHONPATH:-}:${PYTHONPATH:-}

# Cf. utils.sh
show     PYTHONHOME
log_path LD_LIBRARY_PATH
log_path PYTHONPATH

echo "APP_PYTHONPATH: ${APP_PYTHONPATH:-}"
echo "PYTHONPATH: $PYTHONPATH"
echo "PYTHONHOME: ${PYTHONHOME:-}"
export PYTHONPATH

echo "langs-app-lambda done."
