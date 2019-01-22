
# DB INSERT JUNK PY
# Test SQLite DB
# See init-db.sql for the table schema

import datetime
import time
import sqlite3

conn = sqlite3.connect('xcorr.db')
cursor = conn.cursor()

records = []
for i in range(1,11):
    d = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    filename = "file-%i.csv" % i
    source1 = "feature1"
    source2 = "feature2"
    cutoff_corr = 0.9
    cutoff_xcorr = 0.8
    record = (d,filename,source1,source2,cutoff_corr,cutoff_xcorr)
    records.append(record)

def insert_record(cursor, record):
    # print("inserting: " + str(record))
    cmd = "insert into records values %s;" % str(record)
    print("SQL: " + cmd)
    rc = cursor.execute(cmd)

for record in records:
    insert_record(cursor, record)
conn.commit()

conn.close()
