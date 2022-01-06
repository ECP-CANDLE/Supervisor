#!/bin/sh
set -eu

# SHRINK OUTPUT SINGLE SH
# Called by shrink-output.mk

INPUT=$1
OUTPUT=$2

D=/tmp/${USER}/shrink
T=${INPUT/out/tr}

tr "\r" "\n" < $INPUT > $T
python $THIS/shrink-output.py $T $OUTPUT

rm $T
