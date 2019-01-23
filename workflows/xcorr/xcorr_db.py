
# XCORR DB PY
# DB helper functions

import sqlite3
import datetime

import sys

class xcorr_db:

    def __init__(self, db_file):
        self.conn = sqlite3.connect(db_file)
        self.cursor = self.conn.cursor()
        self.id2name = None
        self.name2id = None

    def insert_xcorr_record(self, filename, source1, source2, features,
                            cutoff_corr, cutoff_xcorr):
        """
        Insert a new XCORR record.
        :return: The ID of the new record
        """
        sql = "insert into records values(?, ?, ?, ?, ?, ?)"
        ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        values = (ts, filename, source1, source2,
                  cutoff_corr, cutoff_xcorr)
        print("DB: insert xcorr record: " + str(values))
        self.cursor.execute(sql, values)
        record_id = str(self.cursor.lastrowid)
        print("DB: inserted record: " + record_id)
        for feature in features:
            feature_id = str(self.name2id[feature])
            self.insert("features", (record_id, feature_id))
        return record_id

    def read_feature_names(self):
        cmd = "select rowid, name from feature_names;"
        self.cursor.execute(cmd)
        self.id2name = {}
        self.name2id = {}
        while True:
            row = self.cursor.fetchone()
            if row == None: break
            rowid, name = row[0:2]
            self.id2name[rowid] = name
            self.name2id[name]  = rowid
        return self.id2name, self.name2id

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
