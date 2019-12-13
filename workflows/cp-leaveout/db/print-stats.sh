#!/bin/sh

# PRINT STATS SH

if [ ${#} != 1 ]
then
  echo "$0: Provide: <DB file>"
  exit 1
fi

DB=$1

COMPLETE=$( 
sqlite3 $DB <<EOF
SELECT COUNT(status) FROM runhist WHERE (status="COMPLETE") ;
EOF
)

TOTAL=$( 
sqlite3 $DB <<EOF
SELECT COUNT(status) FROM runhist ;
EOF
)

echo "COMPLETE / TOTAL = $COMPLETE / $TOTAL"
