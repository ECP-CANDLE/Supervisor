#!/bin/bash

# TAR EXPERIMENT

# Create tarball of experiment directory excepting *.h5 and *.tsv files

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          -H "Provide a MODE (STATS or INFER)!" \
          DIR MODE - ${*}

# Get directory named "experiments"
EXPERIMENTS=$( readlink --canonicalize $( dirname $DIR ) )
EXPID=$( basename $DIR )

if [[ $MODE == "STATS" ]]
then
  # For Node.py stats processing
  OPTIONS=( --exclude '*.tsv' --exclude '*.h5' )
  Z="z"
  EXT="tgz"
elif [[ $MODE == "INFER" ]]
then
  # For inferencing runs
  echo "find ..."
  MATCHES=( -name '*.json' -or -name 'uno*.log' -or -name 'uno*.h5' )
  find $DIR ${MATCHES[@]} > tar.list
  OPTIONS=( --files-from=tar.list )
  DIR="" # Unset this- only files in tar.list are included
  Z=""
  EXT="tar"
fi

set -x
nice tar cf$Z $EXPERIMENTS/$EXPID.$EXT ${OPTIONS[@]} $DIR
du -h $EXPERIMENTS/$EXPID.$EXT
