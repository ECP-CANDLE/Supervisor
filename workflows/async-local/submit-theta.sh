#!/bin/bash
set -eu

# SUBMIT THETA
# Runs main.sh on Theta
# Use 'submit-theta.sh -h' for help

usage()
{
  echo "usage: submit-theta [-q QUEUE] [-w WALLTIME] NODES PARALLELISM"
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

if (( ${#} != 2 ))
then
  usage
  exit 1
fi

NODES=$1
PARALLELISM=$2
CONCURRENCY=$(( NODES / PARALLELISM ))
TASKS=$(( CONCURRENCY * 10 ))

TIMESTAMP=$( date "+%Y-%m-%d_%H:%M:%S" )
OUTPUT=output/$TIMESTAMP
LOG=output/$TIMESTAMP.txt
mkdir -p $OUTPUT
echo OUTPUT=$OUTPUT

echo TIMESTAMP=$TIMESTAMP > $LOG
{
  echo NODES=$NODES
  echo PARALLELISM=$PARALLELISM
  echo CONCURRENCY=$CONCURRENCY
  echo TASKS=$TASKS
  echo
} | tee -a $LOG

JOB=$( qsub --project CSC249ADOA01 \
            --queue $QUEUE \
            --nodecount $NODES \
            --time $WALLTIME \
            --output $LOG \
            --error $LOG \
            --env OUTPUT=$OUTPUT \
            ./main.sh $PARALLELISM $CONCURRENCY $TASKS )

echo JOB=$JOB
cqwait $JOB
