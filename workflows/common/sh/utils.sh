
# SH UTILS
# Misc. Bash shell functionality

abort()
# Shut it down
{
  echo "abort:" ${*}
  exit 1
}

is()
{
  if eval "${*}"
  then
    echo 0
  else
    echo 1
  fi
}

check()
# Try to run given command CMD,
# if it fails, print extra error message MSG
{
  if (( ${#} != 2 ))
  then
    echo "check: requires CMD MSG"
    exit 1
  fi
  local CMD=$1
  local MSG=$2
  if $CMD
  then
    return
  fi
  abort $MSG
}

assert()
{
  if (( ${#} != 2 ))
  then
    echo "assert: requires CODE MSG"
    exit 1
  fi
  local CODE=$1
  local MSG=$2
  if (( $CODE ))
  then
    return
  fi
  abort $MSG
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
# Pretty print a colon-separated variable, one entry per line
# Provide the name of the variable (no dollar sign)
{
  # First, test if $1 is the name of a set shell variable:
  if eval test \$\{$1:-\}
  then
    echo ${1}:
    eval echo \$$1 | tr : '\n' | nl
    echo --
    echo
  else
    echo "log_path(): ${1} is unset."
  fi
}

which_check()
# Both Bash which and /bin/which do not produce error messages
# if program is not found
# Use this function instead of raw which!
{
  if (( ${#} == 0 ))
  then
    echo "which_check(): Provide PROGRAMs!"
    exit 1
  fi
  while (( ${#} > 0 ))
  do
    local PROGRAM=$1
    if ! which $PROGRAM
    then
      echo "which_check(): could not find $PROGRAM"
      exit 1
    fi
    shift
  done
}

python_envs()
# Expands to the 'swift-t -e' environment arguments for Python
# Properly handles cases where PYTHONPATH or PYTHONHOME are unset
{
  RESULT=()
  if [[ ${PYTHONPATH:-} != "" ]]
  then
    # We do not currently need this except on MCS and Spock:
    # Swift/T should grab PYTHONPATH automatically
    if [[ ${SITE} == "mcs"      ]] || \
       [[ ${SITE} == "spock"    ]] || \
       [[ ${SITE} == "lambda"   ]] || \
       [[ ${SITE} == "frontier" ]]
    then
      # MCS discards PYTHONPATH in subshells
      RESULT+=( -e PYTHONPATH=$PYTHONPATH )
    fi
  fi
  if [[ ${PYTHONHOME:-} != "" ]]
  then
    RESULT+=( -e PYTHONHOME=$PYTHONHOME )
  fi
  if [[ ${PYTHONUSERBASE:-} != "" ]]
  then
    RESULT+=( -e PYTHONUSERBASE=$PYTHONUSERBASE )
  fi

  if (( ${#RESULT[@]} )) # RESULT may be empty
  then
    # Cannot use echo due to "-e" in RESULT
    R=${RESULT[@]} # Suppress word splitting
    printf -- "%s\n" $R
  fi
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
# EXPID: The name of the new directory under experiments/
#        If the user provides -a, this function will autogenerate
#          a new EXPID under the experiments directory,
#        If EXP_SUFFIX is set in the environment, the resulting
#          EXPID will have that suffix.
# CANDLE_MODEL_TYPE: "BENCHMARKS" or "SINGULARITY"
#        Defaults to "BENCHMARKS"
#        This variable affects the experiment directory structure
# RETURN VALUES: EXPID and TURBINE_OUTPUT are exported into the environment
# TURBINE_OUTPUT is canonicalized, because it may be soft-linked
#    to another filesystem (e.g., on Summit), and must be accessible
#    from the compute nodes without accessing the soft-links
{
  if (( ${#} != 1 ))
  then
    log "get_expid(): provide EXPID or '-a'"
    return 1
  fi

  export EXPID=$1

  if [[ ${MODEL_NAME:-} == "" ]]
  then
    log "get_expid(): MODEL_NAME is unset!"
    return 1
  fi
  : ${CANDLE_MODEL_TYPE:=BENCHMARKS}
  log "get_expid(): CANDLE_MODEL_TYPE=$CANDLE_MODEL_TYPE"
  log "get_expid(): MODEL_NAME=$MODEL_NAME"

  export EXPERIMENTS=""

  if [[ $CANDLE_MODEL_TYPE == "SINGULARITY" ]]
  then
    # Keep this directory in sync with model.sh RUN_DIRECTORY
    MODEL_TOKEN=$( basename $MODEL_NAME .sif )
    EXPERIMENTS=$CANDLE_DATA_DIR/$MODEL_TOKEN/Output
  else # "BENCHMARKS"
    EXPERIMENTS=${EXPERIMENTS:-$EMEWS_PROJECT_ROOT/experiments}
  fi

  local i=0 EXPS E TO

  if [[ $EXPID == "-a" ]]
  then
    shift
    # Search for free experiment number
    if ! mkdir -pv $EXPERIMENTS
    then
      echo "get_expid(): could not make experiments directory:" \
           $EXPERIMENTS
      return 1
    fi
    EXPS=( $( ls $EXPERIMENTS ) )
    if (( ${#EXPS[@]} != 0 ))
    then
      for E in ${EXPS[@]}
      do
        EXPID=$( printf "EXP%03i" $i )${EXP_SUFFIX:-}
        if [[ $E == $EXPID ]]
        then
          i=$(( i + 1 ))
        fi
      done
    fi
    EXPID=$( printf "EXP%03i" $i )${EXP_SUFFIX:-}
    TURBINE_OUTPUT=$EXPERIMENTS/$EXPID
    check_experiment
  else
    TURBINE_OUTPUT=$EXPERIMENTS/$EXPID
  fi
  mkdir -pv $TURBINE_OUTPUT
  TO=$( readlink --canonicalize $TURBINE_OUTPUT )
  if [[ $TO == "" ]]
  then
    echo "get_expid(): could not canonicalize: $TURBINE_OUTPUT"
    exit 1
  fi
  export TURBINE_OUTPUT=$TO
}

next()
# Obtain next available numbered file name matching pattern
#        in global variable REPLY
# E.g., 'next out-%02i' returns 'out-02' if out-00 and out-01 exist.
{
  local PATTERN=$1 FILE="" i=0
  while true
  do
    FILE=$( printf $PATTERN $i )
    [[ ! -e $FILE ]] && break
    let ++i
  done
  REPLY=$FILE
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

  # This becomes a global variable
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
# Sets global variable CFG_PRM
{
  if (( ${#} < 1 ))
  then
    echo "could not find cfg_prm argument!"
    return 1
  fi

  # This becomes a global variable
  CFG_PRM=$1

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
# May provide '-v' multiple times for verbosity
{
  local OPT OPTIONAL="" VERBOSE=0

  while getopts "ov" OPT
  do
    case $OPT in
      o) OPTIONAL="-o"  ;;
      v) (( ++VERBOSE )) ;;
      *) return 1 ;;  # Bash prints an error
    esac
  done
  shift $(( OPTIND - 1 ))

  if (( ${#} != 2 ))
  then
    echo "usage: source_site TOKEN SITE"
    echo "where TOKEN is env, sched, etc."
    echo "  and SITE is frontier, summit, theta, etc."
    return 1
  fi

  local TOKEN=$1
  export SITE=$2

  if [[ ${WORKFLOWS_ROOT:-} == "" ]]
  then
    echo "source_site(): Set WORKFLOWS_ROOT!"
    return 1
  fi

  local NAME=$TOKEN-$SITE.sh

  if ! search_cfg $OPTIONAL $VERBOSE $NAME
  then
    log "source_cfg(): error: not found in SUPERVISOR_PATH: '$NAME'"
    return 1
  fi
  local FILE=$REPLY

  log "source_site(): sourcing $FILE"
  source $FILE
}

source_cfg()
# Source a test cfg file
# Searches SUPERVISOR_PATH
{
  local VERBOSE=0
  while [[ $1 == "-v" ]]
  do
    (( ++ VERBOSE ))
    shift
  done

  if (( ${#} != 1 ))
  then
    echo "usage: source_cfg [-v]* NAME"
    echo "       where NAME is the filename in SUPERVISOR_PATH"
    echo "       or an absolute path"
    echo "  -v : make more verbose"
    echo "returns 1 if not found"
    return 1
  fi

  local NAME=$1

  if ! search_cfg $VERBOSE $NAME
  then
    log "source_cfg(): error: not found in SUPERVISOR_PATH: '$NAME'"
    return 1
  fi

  local FILE=$REPLY
  debug $VERBOSE "source_cfg(): sourcing file: $FILE"
  source $FILE
}

find_cfg()
# Find any file in SUPERVISOR_PATH
{
  local VERBOSE=0
  while [[ $1 == "-v" ]]
  do
    (( ++ VERBOSE ))
    shift
  done

  if (( ${#} != 1 ))
  then
    echo "usage: find_cfg [-v]* NAME"
    echo "       where NAME is the filename in SUPERVISOR_PATH"
    echo "       or an absolute path"
    echo "  -v : make more verbose"
    echo "the result goes into REPLY"
    echo "returns 1 if not found"
    return 1
  fi

  local NAME=$1

  if ! search_cfg $VERBOSE $NAME
  then
    log "find_cfg(): error: not found in SUPERVISOR_PATH: '$NAME'"
    return 1
  fi
  # Result is in REPLY
}

search_cfg()
# Find a configuration file in SUPERVISOR_PATH
# Internal function
# usage: search_cfg [0,1,2] NAME
{
  local VERBOSE=$1 NAME=$2

  # Check for absolute path:
  if [[ ${NAME:0:1} == "/" ]]
  then
    if ! [[ -r $NAME ]]
    then
      log "find_cfg(): error: not found: '$NAME'"
      return 1
    fi
    REPLY=$NAME
    return
  fi

  # Ensure this is set:
  : ${SUPERVISOR_PATH:=}

  local DIR FILE
  # Split on colon:
  for DIR in ${SUPERVISOR_PATH//:/ }
  do
    FILE=$DIR/$NAME
    trace $VERBOSE "find_cfg(): try file:      $FILE"
    if [[ -r $FILE ]]
    then
      REPLY=$FILE
      return
    fi
  done

  # Not found:
  log "source_cfg(): error: not found in SUPERVISOR_PATH: '$NAME'"
  return 1
}

queue_wait()
# INPUT: TURBINE_OUTPUT, MACHINE, and SITE as globals
# Dispatches to queue_wait_site()
{
  if (( ${#} != 0 ))
  then
    echo "queue_wait(): Should have no arguments!"
    return 1
  fi

  echo "queue_wait()..."

  source_site sched $SITE

  if [[ ${MACHINE:-} == "" ]]
  then
    # Local execution
    JOBID=NONE
    return
  fi

  # Scheduled execution
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

  site2=$(echo $SITE | awk -v FS="-" '{print $1}') # ALW 2020-11-15: allow $SITEs to have hyphens in them as Justin implemented for Summit on 2020-10-29, e.g., summit-tf1

  if [[ $site2 == "cori" ]]
  then
    queue_wait_slurm $JOBID
  elif [[ $site2 == "theta" ]]
  then
    queue_wait_cobalt $JOBID
  elif [[ $site2 =~ summit* ]]
  then
    queue_wait_lsf $JOBID
  elif [[ $site2 == "spock" ]]
  then
    queue_wait_slurm $JOBID
  elif [[ $site2 == "pascal" ]]
  then
    queue_wait_slurm $JOBID
  elif [[ $site2 == "biowulf" ]]
  then
    queue_wait_slurm $JOBID
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
    date "+%Y-%m-%d %H:%M:%S"
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
    date "+%Y-%m-%d %H:%M:%S"
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

queue_wait_lsf()
{
  if (( ${#} != 1 ))
  then
    echo "usage: queue_wait_lsf JOBID"
    return 1
  fi

  local JOBID=$1

  local DELAY_MIN=10
  local DELAY_MAX=600
  local DELAY=$DELAY_MIN

  local STATE="PEND"

  while (( 1 ))
  do
    echo -n $( date "+%Y-%m-%d %H:%M:%S" )
    echo " waiting for job $JOBID ($STATE)"

    if ! ( bjobs | grep -q "$JOBID.*$STATE" )
    then
      if [[ $STATE == "PEND" ]]
      then
        echo "Job $JOBID is not pending."
        STATE="RUN"
        DELAY=$DELAY_MIN
      elif [[ $STATE == "RUN" ]]
      then
        break
      fi
    fi
    read -t $DELAY || true
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

trace()
# usage: trace VERBOSITY msg...
{
  log_if 2 $*
}

debug()
# usage: debug VERBOSITY msg...
{
  log_if 1 $*
}

log_if()
# Log if verbosity V is at least at LIMIT
# usage: log_if LIMIT V msg...
# If environment/global VERBOSITY is higher,
#    VERBOSITY is used for V
{
  if (( ${#} < 3 ))
  then
    echo "log_if(): bad arguments: ${*}"
    exit 1
  fi
  local LIMIT=$1 V=$2
  if (( ${VERBOSITY:-0} > V ))
  then
    V=$VERBOSITY
  fi
  if (( V < LIMIT ))
  then
    # Verbosity is not high enough for this message:
    return
  fi
  shift 2
  log $*
}

log()
# General-purpose log line
# Set global LOG_LINE to insert a token
{
  local TOKEN=""
  if [[ ${LOG_NAME:-} != "" ]]
  then
    TOKEN="${LOG_NAME}:"
  fi
  echo $( date "+%Y-%m-%d %H:%M:%S" ) $TOKEN $*
}

error()
{
  log "ERROR:" $*
}

crash()
{
  error $*
  exit 1
}

sv_path_prepend()
{
  SUPERVISOR_PATH=$1${SUPERVISOR_PATH:+:}${SUPERVISOR_PATH:-}
  export SUPERVISOR_PATH
}

sv_path_append()
{
  SUPERVISOR_PATH=${SUPERVISOR_PATH:-}${SUPERVISOR_PATH:+:}$1
  export SUPERVISOR_PATH
}

log_script()
# Provenance dump
{
  SCRIPT_NAME=$(basename $0)
  LOG_NAME="${TURBINE_OUTPUT}/${SCRIPT_NAME}.log"
  echo "### VARIABLES ###" > $LOG_NAME
  # Ignore unset variables herein:
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

pad_keys() {
  # Pad 1st tokens
  # len("train_ml_data_dir")=17
  printf "%-17s " $1
  shift
  echo $*
}

print_json() {
  # Pretty print a Supervisor JSON fragment
  # Uses stdin/stdout
  tr -d '{}' | tr ',":' '\n  ' | \
    while read line
    do
      printf "  "
      pad_keys "$line"
    done
}

signature()
# Gives shell scripts an argument list
# First argument: SELF (the current script)
# Variable names (e.g., X Y Z)
# -
# Variable values (typically ${*}) to be assigned to X Y Z
# Use -H MESSAGE to provide an additional help message
# Use -v for verbose logging of argument assignments
{
  local L # The list of variable names
  L=()
  local SELF=$1 HELP="" VERBOSE=0
  local NL="\n"
  shift
  while getopts "H:v" OPT
  do
    case $OPT in
      H) HELP+="$NL$OPTARG" ;;
      v) VERBOSE=1    ;;
      *) return 1 ;; # Bash prints an error
    esac
  done
  shift $(( $OPTIND - 1 ))
  while true
  do
    if [[ ${1:-} = "-" ]]
    then
      shift
      break
    fi
    L+=( $1 )
    shift || return 1
  done
  if (( ${#L[@]} != ${#*} ))
  then
    echo "$SELF: Requires ${#L[@]} arguments, given ${#*}"
    echo "$SELF: Required arguments: ${L[@]}"
    if (( ${#HELP} ))
    then
      printf "$SELF: Usage: $HELP\n" # Need printf for NLs in HELP
    fi
    exit 1
  fi
  local VARIABLE
  for VARIABLE in ${L[@]}
  do
    (( VERBOSE )) && echo "$SELF: signature(): $VARIABLE=$1"
    eval $VARIABLE=$1
    shift
  done
}

shopt -s expand_aliases
alias SIGNATURE='signature $0'
