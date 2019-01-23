
# DB INSERT JUNK PY
# Test SQLite DB
# See init-db.sql for the table schema

import datetime
import time
import sqlite3

from xcorr_db import xcorr_db, q

DB = xcorr_db('xcorr.db')

for i in range(1,4):
    filename = "file-%i.csv" % i
    source1 = "feature1"
    source2 = "feature2"
    cutoff_corr = 0.9
    cutoff_xcorr = 0.8
    record = (filename,source1,source2,cutoff_corr,cutoff_xcorr)
    DB.insert_xcorr_record(filename, source1, source2, cutoff_corr, cutoff_xcorr)

feature_names = [ "AARS", "ABCB6", "ABCC5" ]
for name in feature_names:
    DB.insert("feature_names", [q(name)])

DB.commit()

names = DB.read_feature_names()
print(names)

DB.close()
