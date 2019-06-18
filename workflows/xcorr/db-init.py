
# DB INIT PY
# Initialize the SQLite DB
# See db-init.sql for the table schema

import sys
from xcorr_db import xcorr_db, q

from pathlib import Path
THIS = Path(sys.argv[0]).parent.resolve()

DB = xcorr_db('xcorr.db')
DB.connect()

def create_tables():
    """ Set up the tables defined in the SQL file """
    global THIS
    with open(str(THIS)+"/db-init.sql") as fp:
        sqlcode = fp.read()
    DB.executescript(sqlcode)
    DB.commit()

def insert_feature_names():
    """
    Copy features from the header of this datafile
    into the features table
    """
    global THIS
    datafile = str(THIS)+"/test_data/combined_rnaseq_data_lincs1000_combat"
    #datafile = "test_data/combined_rnaseq_data_combat"

    with open(datafile) as fp:
        line = fp.readline()

    feature_names = line.split("\t")
    del feature_names[0] # Remove first token "Sample"

    for name in feature_names:
        if name == "": continue
        name = name.strip()
        DB.insert(table="feature_names",
                  names=["name"],
                  values=[q(name)])

def insert_study_names():
    """ Copy study names from studies.txt into the DB """
    global THIS
    studies = []
    with open(str(THIS)+"/studies.txt") as fp:
        while True:
            line = fp.readline()
            if line == "": break
            tokens = line.split("#")
            line = tokens[0]
            line = line.strip()
            if line == "": continue
            studies.append(line)

    for study in studies:
        DB.insert(table="study_names",
                  names=["name"],
                  values=[q(study)])

def create_indices():
    """ Create indices after data insertion for speed """
    DB.execute("create index features_index on features(record_id);")
    DB.execute("create index  studies_index on studies ( study_id);")

# Catch and print all exceptions to improve visibility of success/failure
success = False
try:
    create_tables()
    insert_feature_names()
    insert_study_names()
    create_indices()
    success = True
except Exception as e:
    import traceback
    print(traceback.format_exc())

if not success:
    print("DB: !!! INIT FAILED !!!")
    import sys
    sys.exit(1)

print("DB: initialized successfully")
