# DB HPO SETUP

import os
import sys

import yaml
from xcorr_db import q, xcorr_db

DB = xcorr_db("xcorr.db", log=True)


def ensure_hpo_exists(hpo_id):
    cmd = "select hpo_id from hpo_ids where hpo_id=" + str(hpo_id) + ";"
    DB.cursor.execute(cmd)
    while True:
        row = DB.cursor.fetchone()
        if row == None:
            break
        print("Found in DB: hpo_id=" + str(hpo_id))
        return
    import datetime

    ts = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    DB.insert(table="hpo_ids",
              names=["hpo_id", "time"],
              values=[q(hpo_id), q(ts)])
    print("SQL: created: hpo_id=" + str(hpo_id))


def insert_hyperparam_defns(hpo_id, yamlfile):
    """Copy hyperparameter definitions from YAML to SQL."""
    with open(yamlfile) as fp:
        s = fp.read()
    y = yaml.load(s)
    for hp in y:
        print("hyperparameter '%s' has %2i values" % (hp, len(y[hp]["values"])))
        param_id = DB.insert(
            table="hpo_hyperparam_defns",
            names=["hpo_id", "name"],
            values=[q(hpo_id), q(hp)],
        )
        # print("param_id " + str(param_id))
        values = y[hp]["values"]
        for p in values:
            print(" " + p)
            DB.insert(
                table="hpo_hyperparam_values",
                names=["param_id", "value"],
                values=[q(param_id), q(p)],
            )


def usage():
    print("usage: db-hpo-setup <hpo_id> <yaml>")


if len(sys.argv) != 3:
    usage()
    exit(1)

hpo_id = int(sys.argv[1])
yamlfile = sys.argv[2]

# Catch and print all exceptions to improve visibility of success/failure
success = False
try:
    ensure_hpo_exists(hpo_id)
    insert_hyperparam_defns(hpo_id, yamlfile)
    success = True
except Exception as e:
    import traceback

    print(traceback.format_exc())

if not success:
    print("DB: !!! INIT FAILED !!!")
    exit(1)

print("DB: setup successfully")
