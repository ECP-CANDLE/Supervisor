#!/bin/sh

# PRINT DB SH
# Just print the tables for human inspection

if [ ${#} != 1 ]
then
  echo "Provide a DB file!"
  exit 1
fi

DB=$1

THIS=$( readlink --canonicalize $( dirname $0 ) )

sqlite3 $DB < $THIS/print-db.sql
