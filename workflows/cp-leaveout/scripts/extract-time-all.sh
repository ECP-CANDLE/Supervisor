#!/bin/bash
set -eu

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

TIME_LOG=$DIR/time.log

RUNS=$( ls $DIR/run )
FORMAT="%s,%s,%s %s,%s %s,%s %s,%s %s"

{
  printf "$FORMAT\n" STAGE RUN PRE_RUN_START '' PRE_RUN_STOP '' POST_RUN_START '' POST_RUN_STOP ''
  for RUN in $RUNS
  do
    STAGE=$(( ${#RUN} / 2 ))
    STATS=()
    for TOKEN in 'PRE RUN START' 'PRE RUN STOP' 'POST RUN START' 'POST RUN STOP'
    do
      STATS+=($(sed "/MODEL_RUNNER DEBUG     $TOKEN/ {s/\(.*\) MODEL_RUNNER DEBUG     $TOKEN/\1/ ; h}; \$!d; x" \
                     $DIR/run/$RUN/model.log))
    done
    if [ ${#STATS[@]} -gt 0 ]
    then
      printf "$FORMAT\n" $STAGE $RUN ${STATS[@]}
    fi
  done
} > $TIME_LOG
