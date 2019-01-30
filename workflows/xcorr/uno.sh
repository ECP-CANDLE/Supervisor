#!/bin/bash
set -eu

# UNO SH
# Small wrapper for Uno execution under xcorr with features file

echo "UNO.SH: $*"

fail()
{
  echo "uno.sh:" $*
  exit 1
}

if (( ${#} != 1 ))
then
  fail "provide a single features file!"
fi

FEATURES=$1
if [[ ! -f $FEATURES ]]
then
  fail "features file does not exist: $FEATURES"
fi
# Get the absolute path to the FEATURES file
# (we are going to change PWD)
FEATURES=$( readlink --canonicalize-existing $THIS/$FEATURES ) || \
  fail "could not canonicalize: $FEATURES"

UNO=$BENCHMARKS/Pilot1/Uno/uno_baseline_keras2.py
if [[ ! -f $UNO ]]
then
  fail "could not find UNO: $UNO"
fi

# Convert the FEATURES filename into an output directory name
ID=$( basename $FEATURES )
ID=${ID%_features.txt}
OUTPUT=$EXPERIMENT/$ID
mkdir -pv $OUTPUT
cd $OUTPUT

{
  echo "UNO.SH $*"
  which python
  echo
  python $UNO --cell_feature_subset_path $FEATURES
  echo
  echo "UNO.SH: SUCCESS"
} >& output.txt
