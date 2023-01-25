
# LANGS APP GCE

PATH=/nfs/gce/globalscratch/jain/conda_installs/bin:$PATH

echo "langs-app-gce: using python:"
which python

export PYTHONPATH=${APP_PYTHONPATH:-}
