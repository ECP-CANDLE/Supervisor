#!/bin/bash
set -eu

# MK LOG TAR SH
# Make a tarball with the important logs but not the big datasets

THIS=$( realpath $( dirname $0 ) )

SUPERVISOR=$( realpath $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

cd $DIR

echo "find in $PWD ..."

START=$SECONDS
FILE_LIST=log-tar.list
find . -name python.log    -or \
       -name predicted.tsv -or \
       -name "summ*.txt" > $FILE_LIST
STOP=$SECONDS
COUNT=$( wc -l < $FILE_LIST )

DURATION=$(( STOP - START ))
echo "found $COUNT files in $DURATION seconds."
echo "running tar ..."

START=$SECONDS
TGZ=logs.tgz  # PWD==DIR
nice -n 19 tar czf $TGZ -T $FILE_LIST
STOP=$SECONDS
DURATION=$(( STOP - START ))
SIZE=$( stat --format "%s" $TGZ )
# MB/second:
RATE_MBPS=$(( SIZE / DURATION / 1024 / 1024 ))
# Files/second:
RATE_FPS=$(( COUNT / DURATION ))
echo "tar time: $DURATION seconds at $RATE_MBPS MB/s , $RATE_FPS files/s"

echo "created:"
ls -lh $TGZ
