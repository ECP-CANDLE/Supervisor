
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

get_expid()
# Get Experiment IDentifier
# EXPID is the name of the new directory under experiments/
# If the user provides -a, this function will autogenerate
#   a new EXPID under the experiments directory,
#   which will be exported as TURBINE_OUTPUT
{
  if (( ${#} < 1 ))
  then
    echo "could not find EXPID argument!"
    return 1
  fi

  EXPERIMENTS=$EMEWS_PROJECT_ROOT/experiments

  export EXPID=$1
  if [ $EXPID = "-a" ]
  then
    local i=0
    while (( 1 ))
    do
      EXPID=$( printf "X%03i" $i )
      if [[ -d $EXPERIMENTS/$EXPID ]]
      then
        i=$(( i + i*RANDOM/32767 + 1 ))
      else
        break
      fi
    done
    shift
  fi
  export TURBINE_OUTPUT=$EXPERIMENTS/$EXPID
  check_directory_exists
}

get_cfg_sys()
# Obtain the cfg_sys script file and source it
{
  if (( ${#} < 1 ))
  then
    echo "could not find cfg_sys argument!"
    return 1
  fi

  local CFG_SYS=$1

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
{
  if (( ${#} != 2 ))
  then
    echo "usage: source_site TOKEN SITE"
    echo "where TOKEN is langs, modules, etc."
    echo "  and SITE is titan, cori, theta, etc."
    return 1
  fi

  TOKEN=$1
  SITE=$2

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

  source $FILE
}

queue_wait()
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

  # TODO
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
  echo "Could not find '$TOKEN'"
  show OUTPUT WORKFLOW SCRIPT JOBID
  return 1
}
