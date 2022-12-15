# DB HPO LIST

from xcorr_db import q, xcorr_db


def list_hpos():
    results = []
    cmd = "select hpo_id, time from hpo_ids;"
    DB.execute(cmd)
    while True:
        row = DB.cursor.fetchone()
        if row == None:
            break
        id, t = row[0:2]
        print("r")
        results.append([id, t])
    return results


def list_params(hpo_id):
    """hpo_id is a string here."""
    results = {}
    cmd = ("select param_id, name from hpo_hyperparam_defns " +
           "where hpo_id=%s;" % hpo_id)
    DB.execute(cmd)
    while True:
        row = DB.cursor.fetchone()
        if row == None:
            break
        param_id, name = row[0:2]
        results[param_id] = [name]
    for param_id in results.keys():
        values = list_values(param_id)
        results[param_id].append(values)
    return results


def list_values(param_id):
    """param_id is a string here."""
    results = []
    cmd = ("select value_id, value from hpo_hyperparam_values " +
           "where param_id=%s;" % param_id)
    DB.execute(cmd)
    while True:
        row = DB.cursor.fetchone()
        if row == None:
            break
        value_id, value = row[0:2]
        results.append([value_id, value])
    return results


import argparse

parser = argparse.ArgumentParser(description="Query the DB.")
parser.add_argument("--hpo", action="store", help="specify HPO ID")
parser.add_argument("--list-hpos", action="store_true", help="list HPO IDs")
parser.add_argument("--list-params",
                    action="store_true",
                    help="list hyperparameters")
parser.add_argument("-v",
                    "--verbose",
                    action="store_true",
                    help="echo SQL statements")
args = parser.parse_args()
argv = vars(args)

if argv["verbose"]:
    print(str(args))

DB = xcorr_db("xcorr.db", log=argv["verbose"])


def argv_hpo():
    global argv
    if argv["hpo"] == None:
        print("provide an HPO ID with --hpo")
        exit(1)
    return argv["hpo"]


if argv["list_hpos"]:
    entries = list_hpos()
    for entry in entries:
        print(entry[0], ":", entry[1])

if argv["list_params"]:
    entries = list_params(argv_hpo())
    for param_id in entries.keys():
        print(param_id, ":", entries[param_id][0])
        for value in entries[param_id][1]:
            print("  " + str(value[0]) + " : " + str(value[1]))
