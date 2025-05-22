#!/bin/bash
set -eu

# SHRINK LOG SINGLE SH
# Called by shrink-logs.mk
# or
# Call interactively: shrink-log-single.sh INPUT.log OUTPUT.log
#      where OUTPUT.log may be /dev/stdout or - (meaning stdout)

if (( ${#} != 2 ))
then
  echo "shrink-log-single.sh: provide INPUT OUTPUT"
  exit 1
fi

INPUT=$1
OUTPUT=$2

if [[ $OUTPUT == "-" ]]
then
  OUTPUT=/dev/stdout
fi

TMP_SHRINK=${TMP_SHRINK:-/tmp/$USER}

NAME=$( basename --suffix=.txt $INPUT )

# Temp file for tr output:
T=$( mktemp --tmpdir=$TMP_SHRINK --suffix .txt tr-XXX )

if [[ $INPUT == $T ]]
then
  echo "shrink-log-single.sh: ERROR: INPUT is wrong."
  exit 1
fi

if [[ "${THIS:-}" == "" ]]
then
  THIS=$( readlink --canonicalize $( dirname $0 ) )
fi

# This converts the TensorFlow line overwrite behavior to
# normal newlines:
tr "\r" "\n" < $INPUT > $T

# Does the log parsing and shrinking:
python $THIS/shrink-log.py $T $OUTPUT

rm $T
