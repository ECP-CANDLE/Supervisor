#!/bin/sh
set -eu

# RUN LOGGER

CMD=$1
EMEWS_PROJECT_ROOT=$2
WORKFLOWS_ROOT=$EMEWS_PROJECT_ROOT/..

COMMON_DIR=$EMEWS_PROJECT_ROOT/../../../Benchmarks/common
export PYTHONPATH="$PYTHONPATH:$COMMON_DIR"

if [[ $PYTHONHOME == "" ]]
then
  unset PYTHONHOME
fi

# "start" propose_points, max_iterations, ps, algorithm, exp_id, sys_env
if [ $CMD == "start" ]
  then	
	SITE=$9
	source $WORKFLOWS_ROOT/common/sh/utils.sh
	source_site langs-app $SITE
    arg_array=("$EMEWS_PROJECT_ROOT/../common/python/log_runner.py" "$1" "$3" "$4" "$5" "$6" "$7" "$8")
    python "${arg_array[@]}"
  else
	SITE=$4
	source $WORKFLOWS_ROOT/common/sh/utils.sh
	source_site langs-app $SITE
    arg_array=("$EMEWS_PROJECT_ROOT/../common/python/log_runner.py" "$1" "$3")
    python "${arg_array[@]}"
fi
