set -eu

CMD=$1
EMEWS_PROJECT_ROOT=$2

export PYTHONHOME="/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3"
PYTHON="$PYTHONHOME/bin/python"
export LD_LIBRARY_PATH="$PYTHONHOME/lib:/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/lib:/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/cuda/lib64:/opt/gcc/4.9.3/snos/lib64:/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3x/lib64/R/lib"
export PATH="$PYTHONHOME/bin:$PATH"

COMMON=$EMEWS_PROJECT_ROOT/../../../Benchmarks/common
PYTHONPATH="$PYTHONHOME/lib/python3.6:$COMMON"
PYTHONPATH+=":$PYTHONHOME/lib/python3.6/site-packages"
export PYTHONPATH

# "start" propose_points, max_iterations, ps, algorithm, exp_id, sys_env
if [ $CMD == "start" ]
  then
    arg_array=("$EMEWS_PROJECT_ROOT/../common/python/log_runner.py" "$1" "$3" "$4" "$5" "$6" "$7" "$8")
    python "${arg_array[@]}"
  else
    arg_array=("$EMEWS_PROJECT_ROOT/../common/python/log_runner.py" "$1" "$3")
    python "${arg_array[@]}"
fi
