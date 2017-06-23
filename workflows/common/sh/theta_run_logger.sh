set -eu

CMD=$1
EMEWS_PROJECT_ROOT=$2

export PYTHONHOME="/lus/theta-fs0/projects/Candle_ECP/ncollier/py2_tf_gcc6.3_eigen3_native"
PYTHON="$PYTHONHOME/bin/python"
export LD_LIBRARY_PATH="$PYTHONHOME/lib"
export PATH="$PYTHONHOME/bin:$PATH"

COMMON=$EMEWS_PROJECT_ROOT/../../../Benchmarks/common
PYTHONPATH="$PYTHONHOME/lib/python2.7:$COMMON:"
PYTHONPATH+="$PYTHONHOME/lib/python2.7/site-packages"
export PYTHONPATH

# "start" propose_points, max_iterations, ps, algorithm, exp_id, sys_env
if [ $CMD == "start" ]
  then
    arg_array=("$EMEWS_PROJECT_ROOT/../common/python/log_runner.py" "$1" "$3" "$4" "$5" "$6" "$7" "$8")
    $PYTHON "${arg_array[@]}"
  else
    arg_array=("$EMEWS_PROJECT_ROOT/../common/python/log_runner.py" "$1" "$3")
    $PYTHON "${arg_array[@]}"
fi
