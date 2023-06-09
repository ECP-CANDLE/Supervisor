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

FILES=( $( find . -name python.log -or -name predicted.tsv ) )

echo "found ${#FILES[@]} files."
echo "running tar ..."

TGZ=logs.tgz  # PWD==DIR
time nice -n 19 tar cfz $TGZ ${FILES[@]}

echo "created:"
ls -lh $TGZ
