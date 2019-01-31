#!/bin/bash
set -eu

# XCORR SH
# Main user interface to XCORR workflow
# usage: ./xcorr.sh X042 # a unique experiment ID
#    or: ./xcorr.sh -a   # to create a unique experiment ID

fail()
{
  echo "uno.sh:" $*
  exit 1
}

if (( ${#} != 1 ))
then
  fail "provide an experiment name!"
fi

export THIS
THIS=$( readlink --canonicalize $( dirname $0 ) )

# Set the experiment output directory, unique for this run
export EXPERIMENT=$1
if [[ $EXPERIMENT == "-a" ]]
then
  i=1
  while true
  do
    printf -v EXPERIMENT "$THIS/experiments/X%03i" $i
    [[ ! -d $EXPERIMENT ]] && break
    (( i = i+1 ))
  done
else
  EXPERIMENT="$THIS/experiments/$EXPERIMENT"
fi
echo EXPERIMENT=$EXPERIMENT

# Find the Benchmarks
# Must separate export statement for error checking
export BENCHMARKS
BENCHMARKS=$( readlink --canonicalize-existing ../../../Benchmarks ) || \
  fail "could not find Benchmarks!"

export PYTHONPATH=$THIS

# Run workflow under nice to prevent the Benchmark from
# locking up the system
nice swift-t -l -p xcorr.swift
