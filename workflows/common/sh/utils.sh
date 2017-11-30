
# SH UTILS
# Misc. Bash shell functionality

abort()
# Shut it down
{
  echo "abort:" ${*}
  exit 1
}

show()
# Report variable names with their values
{
  for v in $*
  do
    eval "echo $v=\${$v:-}"
  done
}

log_path()
# Pretty print a colon-separated variable
{
  echo ${1}:
  eval echo \$$1 | tr : '\n' | nl
}

which_check()
{
  if [[ ${#} != 1 ]]
  then
    echo "Provide a PROGRAM!"
    exit 1
  fi
  PROGRAM=$1
  if ! which $PROGRAM
  then
    echo "Could not find $PROGRAM"
    exit 1
  fi
}

python_envs()
# Expands to the 'swift-t -e' environment arguments for Python
# Properly handles cases where PYTHONPATH or PYTHONHOME are unset
{
  RESULT=()
  if [[ ${PYTHONPATH:-} != "" ]]
  then
    RESULT+=( -e PYTHONPATH=$PYTHONPATH )
  fi
  if [[ ${PYTHONHOME:-} != "" ]]
  then
    RESULT+=( -e PYTHONHOME=$PYTHONHOME )
  fi
  # Cannot use echo due to "-e" in RESULT
  R=${RESULT[@]} # Suppress word splitting
  printf -- "%s\n" $R
}

get_site()
# Get site name (Titan, Theta, Cori, etc.)
{
  if (( ${#} < 1 ))
  then
    echo "could not find SITE argument!"
    return 1
  fi
  export SITE=$1
}

check_experiment() {
  if [[ -d $TURBINE_OUTPUT ]]; then
    while true; do
      read -p "Experiment directory exists. Continue? (Y/n) " yn
      yn=${yn:-y}
      case $yn in
          [Yy""]* ) break;;
          [Nn]* ) exit; break;;
          * ) echo "Please answer yes or no.";;
      esac
    done
  fi
}

get_expid()
# Get Experiment IDentifier
# EXPID is the name of the new directory under experiments/
# If the user provides -a, this function will autogenerate
#   a new EXPID under the experiments directory,
#   which will be exported as TURBINE_OUTPUT
# If EXP_SUFFIX is set in the environment, the resulting
#   EXPID will have that suffix.
# EXPID is exported into the environment
{
  if (( ${#} < 1 ))
  then
    echo "could not find EXPID argument!"
    return 1
  fi

  EXPERIMENTS=${EXPERIMENTS:-$EMEWS_PROJECT_ROOT/experiments}

  export EXPID=$1

  if [ $EXPID = "-a" ]
  then
    local i=0
    # Exponential search for free number
    while (( 1 ))
    do
      EXPID=$( printf "X%03i" $i )${EXP_SUFFIX:-}
      if [[ -d $EXPERIMENTS/$EXPID ]]
      then
        i=$(( i + i*RANDOM/32767 + 1 ))
      else
        break
      fi
    done
    shift
    export TURBINE_OUTPUT=$EXPERIMENTS/$EXPID
    check_experiment
  else
    export TURBINE_OUTPUT=$EXPID
  fi
}

get_cfg_sys()
# Obtain the CFG_SYS script file from the command line and source it
# Also sets CFG_SYS as a global variable
{
  if (( ${#} < 1 ))
  then
    echo "could not find cfg_sys argument!"
    return 1
  fi

  CFG_SYS=$1

  if ! [[ -f $CFG_SYS ]]
  then
    echo "CFG_SYS does not exist!"
    show CFG_SYS
    return 1
  fi

  if ! source $CFG_SYS
  then
    echo "Error while sourcing CFG_SYS!"
    show CFG_SYS
    return 1
  fi
}

get_cfg_prm()
# Obtain the cfg_prm script file and source it
{
  if (( ${#} < 1 ))
  then
    echo "could not find cfg_prm argument!"
    return 1
  fi

  local CFG_PRM=$1

  if ! [[ -f $CFG_PRM ]]
  then
    echo "CFG_PRM does not exist!"
    show CFG_PRM
    return 1
  fi

  if ! source $CFG_PRM
  then
    echo "Error while sourcing CFG_PRM!"
    show CFG_PRM
    return 1
  fi
}

source_site()
# Source a settings file for a specific SITE (titan, cori, theta)
# Succeeds with warning message if file is not found
# SITE is exported in the environment
{
  if (( ${#} != 2 ))
  then
    echo "usage: source_site TOKEN SITE"
    echo "where TOKEN is langs, modules, etc."
    echo "  and SITE is titan, cori, theta, etc."
    return 1
  fi

  TOKEN=$1
  export SITE=$2

  if [[ ${WORKFLOWS_ROOT:-} == "" ]]
  then
    echo "Set WORKFLOWS_ROOT!"
    return 1
  fi

  FILE=$WORKFLOWS_ROOT/common/sh/$TOKEN-$SITE.sh
  if ! [[ -f $FILE ]]
  then
    echo "warning: no file: $FILE"
    return 0
  fi
  echo sourcing $FILE
  source $FILE
}

queue_wait()
# Autodetect TURBINE_OUTPUT and do a queue_wait_site()
# Assumes MACHINE and SITE are globals
{
  if (( ${#} != 0 ))
  then
    echo "queue_wait(): Should have no arguments!"
    return 1
  fi

  source_site sched $SITE

  if [[ ${MACHINE:-} == "" ]]
  then
    # Local execution
    TURBINE_OUTPUT=$PWD
    JOBID=NONE
    return
  fi

  # Scheduled execution
  TURBINE_OUTPUT=$( cat turbine-directory.txt )
  JOBID=$( cat $TURBINE_OUTPUT/jobid.txt )
  queue_wait_site $SITE $JOBID
}

queue_wait_site()
# Wait for given JOBID using queue tools for given SITE
{
  if (( ${#} != 2 ))
  then
    echo "usage: queue_wait SITE JOBID"
    echo " where SITE is titan, cori, theta, etc."
    echo " and   JOBID is the job number"
    return 1
  fi

  SITE=$1
  JOBID=$2

  if [[ $SITE == "cori" ]]
  then
    queue_wait_slurm $JOBID
  elif [[ $SITE == "theta" ]]
  then
    queue_wait_cobalt $JOBID
  elif [[ $SITE == "titan" ]]
  then
    queue_wait_pbs $JOBID
  else
    echo "queue_wait(): unknown site: $SITE"
    return 1
  fi

  echo "Job completed: $JOBID"
}

queue_wait_slurm()
{
  if (( ${#} != 1 ))
  then
    echo "usage: queue_wait_slurm JOBID"
    return 1
  fi

  local JOBID=$1

  local DELAY_MIN=30
  local DELAY_MAX=600
  local DELAY=$DELAY_MIN

  local STATE="PD"

  while (( 1 ))
  do
    date "+%Y/%m/%d %H:%M:%S"
    if ! ( squeue | grep "$JOBID.*$STATE" )
    then
      if [[ $STATE == "PD" ]]
      then
        echo "Job $JOBID is not pending."
        STATE="R"
        DELAY=$DELAY_MIN
      elif [[ $STATE == "R" ]]
      then
        break
      fi
    fi
    sleep $DELAY
    (( ++ DELAY ))
    if (( DELAY > DELAY_MAX ))
    then
      DELAY=$DELAY_MAX
    fi
  done
  echo "Job $JOBID is not running."
}

queue_wait_cobalt()
{
  if (( ${#} != 1 ))
  then
    echo "usage: queue_wait_cobalt JOBID"
    return 1
  fi

  # Nothing: Swift already uses cqwait for Cobalt jobs!
}

queue_wait_pbs()
{
  if (( ${#} != 1 ))
  then
    echo "usage: queue_wait_pbs JOBID"
    return 1
  fi

  local JOBID=$1

  local DELAY_MIN=30
  local DELAY_MAX=600
  local DELAY=$DELAY_MIN

  local STATE="PD"

  while (( 1 ))
  do
    date "+%Y/%m/%d %H:%M:%S"
    if ! ( qstat | grep "$JOBID.*$STATE" )
    then
      if [[ $STATE == "PD" ]]
      then
        echo "Job $JOBID is not pending."
        STATE="R"
        DELAY=$DELAY_MIN
      elif [[ $STATE == "R" ]]
      then
        break
      fi
    fi
    sleep $DELAY
    (( ++ DELAY ))
    if (( DELAY > DELAY_MAX ))
    then
      DELAY=$DELAY_MAX
    fi
  done
  echo "Job $JOBID is not running."

}


check_output()
{
  if (( ${#} != 5 ))
  then
    echo "usage: check_output TOKEN OUTPUT WORKFLOW SCRIPT JOBID"
    return 1
  fi

  local TOKEN=$1
  local OUTPUT=$2
  local WORKFLOW=$3
  local SCRIPT=$4
  local JOBID=$5

  if grep "$TOKEN" $OUTPUT > /dev/null
  then
    # Success!
    return 0
  fi

  # Else, report error message
  echo "check_output(): Could not find '$TOKEN' in $OUTPUT"
  show OUTPUT WORKFLOW SCRIPT JOBID
  return 1
}


log_script() {
  SCRIPT_NAME=$(basename $0)
  mkdir -p $TURBINE_OUTPUT
  LOG_NAME="${TURBINE_OUTPUT}/${SCRIPT_NAME}.log"
  echo "### VARIABLES ###" > $LOG_NAME
  set +u
  VARS=( "EMEWS_PROJECT_ROOT" "EXPID" "TURBINE_OUTPUT" \
    "PROCS" "QUEUE" "WALLTIME" "PPN" "TURBINE_JOBNAME" \
    "PYTHONPATH" "R_HOME" "LD_LIBRARY_PATH" "DYLD_LIBRARY_PATH" \
    "TURBINE_RESIDENT_WORK_WORKERS" "RESIDENT_WORK_RANKS" "EQPY" \
    "EQR" "CMD_LINE_ARGS" "MACHINE")
  for i in "${VARS[@]}"
  do
      v=\$$i
      echo "$i=`eval echo $v`" >> $LOG_NAME
  done

  for i in "${USER_VARS[@]}"
  do
      v=\$$i
      echo "$i=`eval echo $v`" >> $LOG_NAME
  done
  set -u

  echo "" >> $LOG_NAME
  echo "## SCRIPT ###" >> $LOG_NAME
  cat $EMEWS_PROJECT_ROOT/swift/$SCRIPT_NAME >> $LOG_NAME
}

check_directory_exists() {
  if [[ -d $TURBINE_OUTPUT ]]; then
    while true; do
      read -p "Experiment directory exists. Continue? (Y/n) " yn
      yn=${yn:-y}
      case $yn in
          [Yy""]* ) break;;
          [Nn]* ) exit; break;;
          * ) echo "Please answer yes or no.";;
      esac
    done
  fi

}
