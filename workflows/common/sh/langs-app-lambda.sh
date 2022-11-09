
# LANGS APP LAMBDA

echo "langs-app-lambda ..."

SFW=/home/woz/Public/sfw

PY=$SFW/Anaconda

PATH=$PY/bin:$PATH

echo "Programs:"
which python

export PYTHONPATH=${APP_PYTHONPATH:-}:${PYTHONPATH:-}

# Cf. utils.sh
log_path APP_PYTHONPATH
log_path PYTHONPATH
log_path LD_LIBRARY_PATH
show     PYTHONHOME

echo "langs-app-lambda done."
