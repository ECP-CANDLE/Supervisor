
# DB HPO INIT PY
# Initialize the SQLite DB for HPO
# See db-hpo-init.sql for the table schema

import os, sys
import yaml

from xcorr_db import xcorr_db, q

DB = xcorr_db('xcorr.db', log=False)

def create_tables(db_hpo_init_sql):
    """ Set up the tables defined in the SQL file """
    with open(db_hpo_init_sql) as fp:
        sqlcode = fp.read()
    DB.executescript(sqlcode)
    DB.commit()

def insert_hyperparam_defns(yamlfile, hpo_id):
    """
    Copy hyperparameter definitions from YAML to SQL
    """

    with open(yamlfile) as fp:
        s = fp.read()
    y = yaml.load(s)
    for hp in y:
        print("hyperparameter '%s' has %2i values" % \
              (hp, len(y[hp]["values"])))
        param_id = DB.insert(table="hpo_hyperparam_defns",
                          names=["hpo_id", "name"],
                          values=[q(hpo_id), q(hp)])
        # print("param_id " + str(param_id))
        values = y[hp]["values"]
        for p in values:
            print(" " + p)
            DB.insert(table="hpo_hyperparam_values",
                      names=["hpo_id","param_id","value"],
                      values=[q(hpo_id),q(param_id),q(p)])

# def create_indices():
#    """ Create indices after data insertion for speed """
#     DB.execute("create index features_index on features(record_id);")
#     DB.execute("create index  studies_index on studies ( study_id);")

def usage():
    print("usage: db-hpo-init <yaml>")

if len(sys.argv) != 2:
    usage()
    exit(1)

yamlfile = sys.argv[1]

# Catch and print all exceptions to improve visibility of success/failure
success = False
try:
    this = os.getenv("THIS")
    db_hpo_init_sql = this + "/db-hpo-init.sql"
    create_tables(db_hpo_init_sql)
    insert_hyperparam_defns(yamlfile, 2)
    success = True
except Exception as e:
    import traceback
    print(traceback.format_exc())

if not success:
    print("DB: !!! INIT FAILED !!!")
    exit(1)

print("DB: initialized successfully")
