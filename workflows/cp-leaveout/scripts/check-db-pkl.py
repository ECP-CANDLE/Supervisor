
# CHECK DB PKL PY
# WIP

import argparse, os, pickle, sys

import sqlite3
from sqlite3 import Error as db_Error

from Node import Node
from utils import abort

parser = argparse.ArgumentParser(description='Parse all log files')
parser.add_argument('directory',
                    help='The experiment directory (EXPID)')

args = parser.parse_args()

node_pkl = args.directory + "/node-info.pkl"
db_file  = args.directory + "/cplo.db"

try: 
    with open(node_pkl, 'rb') as fp:
        data = pickle.load(fp)
except IOError as e:
    abort(e, os.EX_IOERR, "Could not load pickle: " + node_pkl)

try:
    conn = sqlite3.connect(db_file)
except db_Error as e:
    abort(e, os.EX_IOERR, "Could not read DB: " + db_file)

cursor = conn.cursor()
cursor.execute("SELECT subplan_id FROM runhist;")
while True:
    d = cursor.fetchone()
    if d == None:
        break
    print(str(d[0]))
    

cursor.close()
conn.close()
