#!/bin/sh
set -eu

# SHRINK LOG SINGLE SH
# Called by shrink-logs.mk

INPUT=$1
OUTPUT=$2

NAME=$( basename --suffix=.log $INPUT )

T=${INPUT/$NAME/tr}

if [ $INPUT == $T ]
then
  echo "shrink-log-single.sh: ERROR: INPUT is wrong."
  exit 1
fi


if [ "${THIS:-}" == "" ]
then
  THIS=$( readlink --canonicalize $( dirname $0 ) )
fi

tr "\r" "\n" < $INPUT > $T
python $THIS/shrink-log.py $T $OUTPUT

rm $T
