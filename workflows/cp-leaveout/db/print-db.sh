#!/bin/sh

# PRINT DB SH
# Just print the tables for human inspection

THIS=$( readlink --canonicalize $( dirname $0 ) )

sqlite3 $1 < $THIS/print-db.sql
