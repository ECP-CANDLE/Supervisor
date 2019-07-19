#!/bin/sh

# CHECK DB SH
# For now, just dump the tables for human inspection

sqlite3 $1 < check-db.sql
