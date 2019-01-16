
# DB INSERT JUNK PY
# Test SQLite DB
# See init-db.sql for the table schema

import datetime
import time    
import sqlite3

conn = sqlite3.connect('xcorr.db')
cursor = conn.cursor()

records = []
for i in range(0,10):
    d = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    data = str(i)
    record = (d,data)
    records.append(record)

def insert_record(cursor, record):
    cursor.execute("insert into records values (?, ?);", record)
    
for record in records:
    insert_record(cursor, record)
