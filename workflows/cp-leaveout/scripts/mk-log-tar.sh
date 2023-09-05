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
       -name NO-DATA.txt       \
        > $FILE_LIST
#        -name predicted.tsv -or
#        -name "summ*.txt"
STOP=$SECONDS
COUNT=$( wc -l < $FILE_LIST )
DURATION=$(( STOP - START ))
if (( DURATION == 0 ))
then
  DURATION=1  # Prevent DIV0
fi
RATE_FPS=$(( COUNT / DURATION ))

echo "found $COUNT files in $DURATION seconds at $RATE_FPS files/s"
echo "running tar ..."

START=$SECONDS
TGZ=logs.tgz  # PWD==DIR

# Do the tar!
nice -n 19 tar czf $TGZ -T $FILE_LIST

STOP=$SECONDS
DURATION=$(( STOP - START ))
if (( DURATION == 0 ))
then
  DURATION=1  # Prevent DIV0
fi
SIZE=$( stat --format "%s" $TGZ )
# MB/second:
RATE_MBPS=$( bc <<END
scale = 2
$SIZE / $DURATION / 1024 / 1024
END
)
# Files/second:
RATE_FPS=$(( COUNT / DURATION ))
echo "tar time: $DURATION seconds at $RATE_MBPS MB/s , $RATE_FPS files/s"

echo "created:"
ls -lh $TGZ
