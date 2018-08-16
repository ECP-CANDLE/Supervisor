#!/bin/bash
set -eu

# TEST ALL
# Just run this with the site: cori, titan, or theta

if (( ${#} != 1 ))
then
  echo "usage: test-all.sh <SITE>"
  exit 1
fi

SITE=$1

THIS=$( dirname $0 )

# Status:
# Initial indicate who is working on it
# ? means unknown
# P1B1 Theta(RJ?)   Titan(RJ)    Cori(JW NOPE)
# P3B1 Theta(?)     Titan(JW,RJ) Cori(JW 8/25)
# NT3  Theta(JW,PB) Titan(RJ?)   Cori(JW 8/25)

# General test invocation signature:
# TEST SITE BENCHMARK (DIRECTORY CFGs)

# set e # Run through errors here
# $THIS/p1b1_mlrMBO/test/test-1.sh $SITE || true
# $THIS/p3b1_mlrMBO/test/test-1.sh $SITE || true
# $THIS/nt3_mlrMBO/test/test-1.sh  $SITE || true

for BENCHMARK in p1b1 p3b1 nt3 combo
do
  # for ALGORITHM in grid random mlrMBO
  # do
    # $THIS/$ALGORITHM/test/test-1.sh $SITE $BENCHMARK
  set -x
  $THIS/mlrMBO/test/test-1.sh $BENCHMARK $SITE
  # done
done

# $THIS/p2b1_mlrMBO/test/test-1.sh  $SITE
$THIS/grid/test/test-1.sh  p1b1 $SITE || true
$THIS/random/test/test-1.sh  p1b1 $SITE || true

echo "test-all: SUCCESS"
