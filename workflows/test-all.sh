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

                                       # Status (? means unknown):
$THIS/p1b1_mlrMBO/test/test-1.sh $SITE # Theta(RJ?)   Titan(RJ)  Cori(JW NOPE)
$THIS/p3b1_mlrMBO/test/test-1.sh $SITE # Theta(?)     Titan(JW)  Cori(JW 8/25)
$THIS/nt3_mlrMBO/test/test-1.sh  $SITE # Theta(JW,PB) Titan(RJ?) Cori(JW)

echo "test-all: SUCCESS"
