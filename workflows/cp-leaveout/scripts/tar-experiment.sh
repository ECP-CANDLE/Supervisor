#!/bin/bash

# TAR EXPERIMENT

# Create tarball of experiment directory excepting *.h5 and *.tsv files

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

# Get directory named "experiments"
EXPERIMENTS=$( readlink --canonicalize $( dirname $DIR ) )
EXPID=$( basename $DIR )

set -x
nice tar cfz $EXPERIMENTS/$EXPID.tgz --exclude '*.h5' --exclude '*.tsv' $DIR
