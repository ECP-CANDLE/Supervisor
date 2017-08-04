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

$THIS/p3b1_mlrMBO/test/test-1.sh $SITE

echo "test-all: SUCCESS"
