#!/bin/sh
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

$THIS/p1b1_mlrMBO/test/test-1.sh $SITE
$THIS/p3b1_mlrMBO/test/test-1.sh $SITE
$THIS/nt3_mlrMBO/test/test-1.sh  $SITE

# $THIS/p2b1_mlrMBO/test/test-1.sh  $SITE
$THIS/p1b1_grid/test/test-1.sh  $SITE
$THIS/p1b1_random/test/test-1.sh  $SITE

echo "test-all: SUCCESS"
