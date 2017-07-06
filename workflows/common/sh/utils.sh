
# SH UTILS
# Misc. Bash shell functionality

show()
# Report variable names with their values
{
  for v in $*
  do
    eval echo $v=\$$v
  done
}

log_path()
# Pretty print a colon-separated variable
{
  echo ${1}:
  eval echo \$$1 | tr : '\n' | nl
}

get_expid()
# Get Experiment IDentifier
# EXPID is the name of the new directory under experiments/
# If the user provides -a, this script will ask Swift/T to
#   autogenerate a unique EXPID under experiments,
#   which will be reported as TURBINE_OUTPUT
{
  if [ "${#}" -ne 1 ]; then
    script_name=$(basename $0)
    echo << EOF
Usage: ${script_name} EXPERIMENT_ID"
where EXPERIMENT_ID will be the new directory under experiments
EOF
    exit 1
  fi

  export EXPID=$1
  if [ $EXPID = "-a" ]
  then
    export TURBINE_OUTPUT_ROOT=$EMEWS_PROJECT_ROOT/experiments
    # Creates a X + a unique integer padded to 3 digits: e.g., X023
    export TURBINE_OUTPUT_FORMAT="X%Q"
    EXPID="AUTO"
    shift
  else
    export TURBINE_OUTPUT=$EMEWS_PROJECT_ROOT/experiments/$EXPID
    check_directory_exists
  fi
}
