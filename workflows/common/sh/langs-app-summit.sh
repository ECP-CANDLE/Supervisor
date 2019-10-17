# LANGS APP SUMMIT SH

# WIP 2019-02-28

APP_PYTHONPATH=${APP_PYTHONPATH:-$PYTHONPATH}
echo "APP_PYTHONPATH: $APP_PYTHONPATH"

# Clear anything set by the system or Swift/T environment
unset PYTHONPATH
unset LD_LIBRARY_PATH

# module list
# module load ibm-wml/2019.03-CE
# export PYTHONPATH=$APP_PYTHONPATH


# ROOT=/ccs/proj/med106/gounley1/summit
# ROOT=/ccs/proj/med106/hsyoo/summit
# ROOT=/sw/summit/ibm-wml/anaconda-powerai-1.6.1
# export PY=/sw/summit/ibm-wml/anaconda-powerai-1.6.1
# export LD_LIBRARY_PATH=/sw/summit/cuda/10.1.168/lib64:/sw/summit/gcc/4.8.5/lib64:$PY/lib
# export LD_LIBRARY_PATH=$PY/lib
# export PYTHONHOME=$PY
# export PATH=$PYTHONHOME/bin:$PATH
# export PYTHONPATH=$PYTHONHOME/lib/python3.6:$PYTHONHOME/lib/python3.6/site-packages:$APP_PYTHONPATH

ROOT=/ccs/proj/med106/hsyoo/summit
export PY=$ROOT/conda36
export LD_LIBRARY_PATH=/sw/summit/cuda/10.1.168/lib64:/sw/summit/gcc/4.8.5/lib64:$PY/lib
export PYTHONHOME=$ROOT/conda36
export PATH=$PYTHONHOME/bin:$PATH
export PYTHONPATH=$PYTHONHOME/lib/python3.6:$PYTHONHOME/lib/python3.6/site-packages:$APP_PYTHONPATH
