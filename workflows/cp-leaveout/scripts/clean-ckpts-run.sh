#!/bin/bash
set -eu

# CLEAN CKPTS RUN SH

# See ./clean-ckpts.sh

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an run DIR (e.g., .../experiments/X042/run/1.2.3)!" \
          DIR - ${*}

if [[ ! -d $DIR ]]
then
  echo "$0: Given run directory does not exist: $DIR"
  exit 1
fi

echo "RUN: $DIR"

if ! [[ -d $DIR/save/ckpts/epochs ]]
then
  echo "No epochs directory."
  exit
fi

cd $DIR/save/ckpts/epochs
MODELS=( $( ls ) )

N=${#MODELS[@]}
echo "MODELS: $N"

# Do not clean the last 3 models
for (( i=0 ; i<$N-3 ; i++ ))
do
  MODEL=${MODELS[$i]}
  # Use 10# to force MODEL as base-10
  # (Bash treats e.g. MODEL=010 as octal)
  if (( 10#$MODEL % 5 == 0 ))
  then
    continue
  fi
  if ! [[ -f $MODEL/model.h5 ]]
  then
    continue
  fi
  rm -v $MODEL/model.h5
done
