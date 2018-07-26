#!/bin/bash
set -eu

# SUBMIT THETA
# Runs main.sh on Theta
# Use 'submit-theta.sh -h' for help

THIS=$( dirname $0 )

usage()
{
  echo "usage: submit-theta [-q QUEUE] [-w WALLTIME] NODES <MAIN ARGS>"
  echo "main.py args are:"
  $THIS/main.sh -h
}

# Defaults:
QUEUE="default"
WALLTIME=00:02:00

while getopts "hq:w:" OPTION
do
  case $OPTION in
    h) usage ; exit 0 ;;
    q) QUEUE=$OPTARG ;;
    w) WALLTIME=$OPTARG ;;
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
shift

TIMESTAMP=$( date "+%Y-%m-%d_%H:%M:%S" )
OUTPUT=output/$TIMESTAMP
LOG=output/$TIMESTAMP.txt
mkdir -p $OUTPUT
echo OUTPUT=$OUTPUT

echo TIMESTAMP=$TIMESTAMP > $LOG
{
  echo NODES: $NODES
  echo MAIN ARGS: $*
  echo
} | tee -a $LOG

JOB=$( qsub --project CSC249ADOA01 \
            --queue $QUEUE \
            --nodecount $NODES \
            --time $WALLTIME \
            --output $LOG \
            --error $LOG \
            --env OUTPUT=$OUTPUT \
            ./main.sh $* )

echo JOB=$JOB
cqwait $JOB
