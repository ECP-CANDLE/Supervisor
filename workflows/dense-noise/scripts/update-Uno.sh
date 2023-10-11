#!/bin/zsh
set -eu

# UPDATE UNO
# Use this to update a SIF with the latest code from the local directories
# It overwrites the existing Uno.sif, but backups are made.
# Update your code directories as needed below:
# Uno.sif is 3GB, so monitor how many backups you have.

if (( ${#*} != 3 ))
then
  echo "Provide CANDLE_LIB BENCHMARKS OUTPUT_DIR"
  exit 1
fi

CANDLE_LIB=$1
BENCHMARKS=$2
OUTPUT_DIR=$3

SIF=$OUTPUT_DIR/Uno.sif

export SINGULARITY_CACHEDIR=/tmp/$USER/singularity-cache
mkdir -pv $SINGULARITY_CACHEDIR

# Get the directory containing this script:
THIS=${0:A:h}

SIF=$OUTPUT_DIR/Uno.sif
if [[ -f $SIF ]]
then
  # Make a backup.
  # The backup will be used as the base container by the def script:
  mv -v --backup=numbered $SIF $SIF.bak
else
  if [[ ! -f $SIF.bak ]]
  then
    echo "Not found: $SIF or $SIF.bak"
    echo "Run build-Uno.sh first!"
    exit 1
  fi
fi

singularity build --fakeroot --force \
    --bind $BENCHMARKS:/tmp/Benchmarks \
    --bind $CANDLE_LIB:/tmp/candle_lib \
    $SIF $THIS/Uno-update.def

echo "created: $SIF"
