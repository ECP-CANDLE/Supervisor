#!/bin/zsh
set -eu

# BUILD UNO

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

singularity build --fakeroot --force \
    --bind $BENCHMARKS:/tmp/Benchmarks \
    --bind $CANDLE_LIB:/tmp/candle_lib \
    $SIF $THIS/Uno.def

echo "created: $SIF"
