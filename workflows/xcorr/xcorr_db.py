import sqlite3
import datetime

import sys

conn = None

def init(db_file):
    global conn
    conn = sqlite3.connect(db_file)

def insert_xcorr_record(filename, source1, source2, cutoff_corr, cutoff_xcorr):
    sql = "insert into records values(?, ?, ?, ?, ?, ?)"
    cursor = conn.cursor()
    ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    cursor.execute(sql, (ts, filename, source1, source2, cutoff_corr, cutoff_xcorr))
    conn.commit()
