
# DB CPLO INIT PY
# Initialize the SQLite DB for CP LEAVE OUT
# See db-cplo-init.sql for the table schema

import os, sys
import yaml

from xcorr_db import xcorr_db, q

import argparse
parser = argparse.ArgumentParser(description="Setup the CPLO DB.")
parser.add_argument("db", action="store", help="specify DB file")
args = parser.parse_args()
argv = vars(args)

DB = xcorr_db(argv["db"], log=False)

def create_tables(db_cplo_init_sql):
    """ Set up the tables defined in the SQL file """
    global DB
    DB.connect()
    with open(db_cplo_init_sql) as fp:
        sqlcode = fp.read()
    DB.executescript(sqlcode)
    DB.commit()

# def create_indices():
#    """ Create indices after data insertion for speed """
#     DB.execute("create index features_index on features(record_id);")
#     DB.execute("create index  studies_index on studies ( study_id);")

# Catch and print all exceptions to improve visibility of success/failure
success = False
try:
    this = os.getenv("THIS")
    db_cplo_init_sql = this + "/db-cplo-init.sql"
    create_tables(db_cplo_init_sql)
    success = True
except Exception as e:
    import traceback
    print(traceback.format_exc())

if not success:
    print("DB: !!! INIT FAILED !!!")
    exit(1)

print("DB: initialized successfully")
