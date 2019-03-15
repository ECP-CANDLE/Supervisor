
# DB HPO LIST

from xcorr_db import xcorr_db, q

def list_hpos():
    results = []
    cmd = "select * from hpo_ids;"
    DB.execute(cmd)
    while True:
        row = DB.cursor.fetchone()
        if row == None: break
        id, t = row[0:2]
        results.append([id,t])
    return results

import argparse
parser = argparse.ArgumentParser(description="Query the DB.")
parser.add_argument("--ids", action="store_true", help="list HPO IDs")
parser.add_argument("--id", action="store", help="specify HPO ID")
parser.add_argument("-v", "--verbose", action="store_true", help="echo SQL statements")
args = parser.parse_args()
argv = vars(args)
# print(str(args))

DB = xcorr_db('xcorr.db', log=argv["verbose"])

if "ids" in argv:
    entries = list_hpos()
    for entry in entries:
        print(entry[0], ":", entry[1])
