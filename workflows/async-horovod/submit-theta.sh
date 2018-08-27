#!/bin/bash
set -eu

# SUBMIT THETA
# Runs main.sh on Theta
# Use 'submit-theta.sh -h' for help

THIS=$( readlink --canonicalize-existing $( dirname $0 ) )

usage()
{
  echo "usage: submit-theta [-q QUEUE] [-w WALLTIME] NODES OUTPUT <MAIN ARGS>"
  echo "       OUTPUT is appended to MAIN ARGS"
  echo "main.py args are:"
  $THIS/main.sh -h
}

# Defaults:
QUEUE="default"
WALLTIME=00:02:00
WAIT=0

while getopts "hq:w:W" OPTION
do
  case $OPTION in
    h) usage ; exit 0 ;;
    q) QUEUE=$OPTARG ;;
    w) WALLTIME=$OPTARG ;;
    W) WAIT=1 ;;
    *) exit 1 ;;
  esac
done
shift $(( OPTIND - 1 ))

# See main.py:parse_args() for argument count (plus 1 for NODES)
if (( ${#} != 6 ))
then
  usage
  exit 1
fi

NODES=$1
OUTPUT=$2
shift 2
# Remaining arguments are passed through to Python via MAIN_ARGS

# Handle relative path in user input:
OUTPUT=$( readlink --canonicalize-missing $OUTPUT )
# Construct arguments passed to Python:
MAIN_ARGS=( $* $OUTPUT )

# Set up output:
mkdir -p $OUTPUT
cd $OUTPUT
MAIN_OUT=$OUTPUT/main.txt
COBALT_OUT=$OUTPUT/cobalt.log

PROJECT=CSC249ADOA01
BENCHMARKS=$( readlink --canonicalize-existing $THIS/../../../Benchmarks || \
                echo "Could not find BENCHMARKS!" >&2 )
if [[ ${BENCHMARKS} == "" ]]
then
  exit 1
fi

{
  echo "SUBMIT: MAIN"
  echo -n "QSUB:      " ; date "+%Y-%m-%d %H:%M %p"
  echo "LOGIN:    " $( hostname )
  echo "NODES:      $NODES"
  echo "MAIN ARGS:  ${MAIN_ARGS[@]}"
  echo "BENCHMARKS: $BENCHMARKS"
  echo "OUTPUT:     $OUTPUT"
  echo
} | tee $MAIN_OUT

QSUB_OPTS=( --project   $PROJECT
            --queue     $QUEUE
            --nodecount $NODES
            --time      $WALLTIME
            --output    $MAIN_OUT
            --error     $MAIN_OUT
            --debuglog  $COBALT_OUT # Normally jobid.cobaltlog
            --env       BENCHMARKS=$BENCHMARKS
          )

if [[ -f $COBALT_OUT ]]
then
  # Cobalt will append to this file: must truncate it
  echo > $COBALT_OUT
fi

JOB=$( qsub ${QSUB_OPTS[@]} $THIS/main.sh ${MAIN_ARGS[@]} )

echo "JOB: $JOB"
echo $JOB > $OUTPUT/job.txt

if (( ! WAIT ))
then
  exit 0
fi

echo "cqwait $JOB ..."
cqwait $JOB
echo "cqwait $JOB done."

{
  echo
  echo -n "QWAIT: "
  date "+%Y-%m-%d %H:%M %p"
} | tee -a $MAIN_OUT
