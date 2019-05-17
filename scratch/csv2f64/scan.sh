#!/bin/sh

# SCAN SH
# Report the rows/cols for the CSV

if [ ${#} != 1 ]
then
  echo "Provide the CSV!"
  exit 1
fi
CSV=$1

echo -n "rows: "
head -1 $CSV | tr ',' ' ' | wc -w
echo -n "cols: "
wc -l < $CSV
