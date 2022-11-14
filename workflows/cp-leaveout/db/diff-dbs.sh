#!/bin/sh

# DIFF DBS SH
# Diff the tables for human inspection

if [ ${#} != 2 ]
then
  echo "Provide 2 DB files!"
  exit 1
fi

DB1=$1
DB2=$2

TXT1=$( mktemp db1.XXX )
TXT2=$( mktemp db2.XXX )

THIS=$( readlink --canonicalize $( dirname $0 ) )

sqlite3 $DB1 < $THIS/print-db.sql > $TXT1
sqlite3 $DB2 < $THIS/print-db.sql > $TXT2

diff $TXT1 $TXT2

rm $TXT1 $TXT2
