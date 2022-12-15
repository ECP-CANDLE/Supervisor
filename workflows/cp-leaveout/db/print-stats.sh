#!/bin/sh
set -eu

# PRINT STATS SH

if [ ${#} != 1 ]
then
  echo "$0: Provide: <DB file>"
  exit 1
fi

DB=$1

if ! which sqlite3 > /dev/null
then
  echo "print-stats.sh: Add sqlite3 to PATH!"
  exit 1
fi

COMPLETE=$(
sqlite3 $DB <<EOF
SELECT COUNT(status) FROM runhist WHERE (status="COMPLETE") ;
EOF
)

SKIPPED=$(
sqlite3 $DB <<EOF
SELECT COUNT(status) FROM runhist WHERE (status="SKIP") ;
EOF
)

TOTAL=$(
sqlite3 $DB <<EOF
SELECT COUNT(status) FROM runhist ;
EOF
)

REMAIN=$(( $TOTAL - $COMPLETE ))

echo "COMPLETE / TOTAL = $COMPLETE / $TOTAL"
echo "remaining: $REMAIN skipped: $SKIPPED"
