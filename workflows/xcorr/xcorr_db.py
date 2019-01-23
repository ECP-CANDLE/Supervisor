
# XCORR DB PY
# DB helper functions

import sqlite3
import datetime

import sys

class xcorr_db:

    def __init__(self, db_file):
        self.conn = sqlite3.connect(db_file)
        self.cursor = self.conn.cursor()

    def insert_xcorr_record(self, filename, source1, source2, cutoff_corr, cutoff_xcorr):
        sql = "insert into records values(?, ?, ?, ?, ?, ?)"
        ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        values = (ts, filename, source1, source2, cutoff_corr, cutoff_xcorr)
        print("DB: insert xcorr record: " + str(values))
        self.cursor.execute(sql, values)

    def insert(self, table, values):
        tpl = sql_tuple(values)
        cmd = "insert into %s values %s;" % (table, tpl)
        print("SQL: " + cmd)
        self.cursor.execute(cmd)

    def execute(self, cmd):
        self.cursor.execute(cmd)

    def commit(self):
        self.conn.commit()

    def close(self):
        self.conn.close()

def q(s):
    """ Quote the given string """
    return "'" + str(s) + "'"

def sql_tuple(L):
    """ Make the given list into a SQL-formatted tuple """
    result = ""
    result += "("
    result += ",".join(L)
    result += ")"
    return result
