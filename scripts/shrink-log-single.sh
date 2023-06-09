#!/bin/sh
set -eu

# SHRINK LOG SINGLE SH
# Called by shrink-logs.mk

INPUT=$1
OUTPUT=$2

NAME=$( basename --suffix=.txt $INPUT )

# Temp file for tr output:
T=$( mktemp --tmpdir=$TMP_SHRINK --suffix .txt tr-XXX )

if [ $INPUT == $T ]
then
  echo "shrink-log-single.sh: ERROR: INPUT is wrong."
  exit 1
fi

if [ "${THIS:-}" == "" ]
then
  THIS=$( readlink --canonicalize $( dirname $0 ) )
fi

# This converts the TensorFlow line overwrite behavior to
# normal newlines:
tr "\r" "\n" < $INPUT > $T

# Does the log parsing and shrinking:
python $THIS/shrink-log.py $T $OUTPUT

rm $T
