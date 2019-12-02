#!/bin/sh

# CHECK DB SH
# For now, just dump the tables for human inspection

THIS=$( readlink --canonicalize $( dirname $0 ) )

sqlite3 $1 < $THIS/check-db.sql
