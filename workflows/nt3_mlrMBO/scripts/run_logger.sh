set -eu

CMD=$1
EMEWS_PROJECT_ROOT=$2

COMMON_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/common
export PYTHONPATH="$COMMON_DIR"

# "start" propose_points, max_iterations, ps, algorithm, exp_id, sys_env
if [ $CMD == "start" ]
  then
    arg_array=("$EMEWS_PROJECT_ROOT/python/log_runner.py" "$1" "$3" "$4" "$5" "$6" "$7" "$8")
    python "${arg_array[@]}"
  else
    arg_array=("$EMEWS_PROJECT_ROOT/python/log_runner.py" "$1" "$3")
    python "${arg_array[@]}"
fi
