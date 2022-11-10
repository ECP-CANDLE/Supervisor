# DB HPO INIT PY
# Initialize the SQLite DB for HPO
# See db-hpo-init.sql for the table schema

import os
import sys

import yaml
from xcorr_db import q, xcorr_db

DB = xcorr_db("xcorr.db", log=False)


def create_tables(db_hpo_init_sql):
    """Set up the tables defined in the SQL file."""
    with open(db_hpo_init_sql) as fp:
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
    db_hpo_init_sql = this + "/db-hpo-init.sql"
    create_tables(db_hpo_init_sql)
    success = True
except Exception as e:
    import traceback

    print(traceback.format_exc())

if not success:
    print("DB: !!! INIT FAILED !!!")
    exit(1)

print("DB: initialized successfully")
