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

if (( ${#} != 3 ))
then
  fail "provide one features file, study1 and preprocess rnaseq value!"
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

STUDY1=$2
PREPROP_RNASEQ=$3

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

DRYRUN=${DRYRUN:-}

{
  echo "UNO.SH $*"
  echo "DATE:" $( date "+%Y-%m-%d %H:%M:%S" )
  which python
  echo
  $DRYRUN python $UNO --cell_feature_subset_path $FEATURES --train_sources $STUDY1 --preprocess_rnaseq $PREPROP_RNASEQ
  echo
  echo "UNO.SH: SUCCESS"
} >& output.txt
