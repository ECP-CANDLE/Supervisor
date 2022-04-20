#!/bin/sh
set -eu

# SHRINK OUTPUT SINGLE SH
# Called by shrink-output.mk

INPUT=$1
OUTPUT=$2

T=${INPUT/out/tr}

if [ $INPUT == $T ]
then
  echo "shrink-output-single.sh: ERROR: INPUT is wrong."
  exit 1
fi

tr "\r" "\n" < $INPUT > $T
python $THIS/shrink-output.py $T $OUTPUT

rm $T
