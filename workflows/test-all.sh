#!/bin/sh
set -eu

# TEST ALL
# Just run this with the site: cori, titan, theta

if (( ${#} != 1 ))
then
  echo "usage: test-all.sh <SITE>"
  exit 1
fi

SITE=$1

THIS=$( dirname $0 )

# Rajeev
$THIS/p1b1_mlrMBO/test/test-1.sh $SITE # Theta((RJ*)) Titan((RJ))
$THIS/p3b1_mlrMBO/test/test-1.sh $SITE # WORKS: Cori(JW), Titan(JW, RJ)
$THIS/nt3_mlrMBO/test/test-1.sh  $SITE # WORKS: Theta(JW,PB) Titan(RJ)

echo "test-all: SUCCESS"
