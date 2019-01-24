
# DB INIT PY
# Initialize the SQLite DB
# See init-db.sql for the table schema

from xcorr_db import xcorr_db, q

DB = xcorr_db('xcorr.db')

def create_tables():
    with open("db-init.sql") as fp:
        sqlcode = fp.read()
    DB.executescript(sqlcode);
    DB.commit()

def insert_feature_names():
    datafile = "test_data/combined_rnaseq_data_lincs1000_combat"

    with open(datafile) as fp:
        line = fp.readline()

    feature_names = line.split("\t")
    del feature_names[0] # Remove first token "Sample"

    for name in feature_names:
        if name == "": continue
        name = name.strip()
        DB.insert("feature_names", [q(name)])

def insert_study_names():
    """ Copy study names from studies.txt into the DB """
    studies = []
    with open("studies.txt") as fp:
        while True:
            line = fp.readline()
            if line == "": break
            tokens = line.split("#")
            line = tokens[0]
            line = line.strip()
            if line == "": continue
            studies.append(line)

    for study in studies:
        DB.insert("study_names", [q(study)])

create_tables()
insert_feature_names()
insert_study_names()
