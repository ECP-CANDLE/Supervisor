
# DB INSERT JUNK PY
# Test SQLite DB
# See init-db.sql for the table schema

import datetime
import random
import sqlite3
import time

from xcorr_db import xcorr_db, q

DB = xcorr_db('xcorr.db')

feature_names = [ "AARS", "ABCB6", "ABCC5" ]
for name in feature_names:
    DB.insert("feature_names", [q(name)])
id2name, name2id = DB.read_feature_names()
print(id2name)
print(name2id)

for i in range(1,4):
    filename = "file-%i.csv" % i
    study1 = "study1"
    study2 = "study2"
    cutoff_corr = 0.9
    cutoff_xcorr = 0.8
    features = [ id for id in feature_names
                 if random.randint(0,1) == 0 ]
    # print(features)
    record = (filename,features,cutoff_corr,cutoff_xcorr)
    DB.insert_xcorr_record(filename, study1, study2, features,
                           cutoff_corr, cutoff_xcorr)

DB.commit()
DB.close()
