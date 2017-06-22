set -eu

CMD=$1
EMEWS_PROJECT_ROOT=$2

export PYTHONHOME="/home/brettin/anaconda2/envs/vrane"
PYTHON="$PYTHONHOME/bin/python"
export LD_LIBRARY_PATH="$PYTHONHOME/lib"
export PATH="$PYTHONHOME/bin:$PATH"

COMMON=$emews_root/../../../Benchmarks/common
PYTHONPATH="$PYTHONHOME/lib/python2.7:$COMMON"
PYTHONPATH+="$PYTHONHOME/lib/python2.7/site-packages"
export PYTHONPATH

# "start" propose_points, max_iterations, ps, algorithm, exp_id, sys_env
if [ $CMD == "start" ]
  then
    arg_array=("$EMEWS_PROJECT_ROOT/python/log_runner.py" "$1" "$3" "$4" "$5" "$6" "$7" "$8")
    python "${arg_array[@]}"
  else
    arg_array=("$EMEWS_PROJECT_ROOT/python/log_runner.py" "$1" "$3")
    python "${arg_array[@]}"
fi
