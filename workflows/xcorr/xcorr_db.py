
# XCORR DB PY
# DB helper functions

import sqlite3
import datetime

import sys

class xcorr_db:

    def __init__(self, db_file):
        self.conn = sqlite3.connect(db_file)
        self.cursor = self.conn.cursor()
        self.feature_id2name = None
        self.feature_name2id = None
        self.study_id2name   = None
        self.study_name2id   = None
        self.autoclose = True

    def insert_xcorr_record(self, filename, studies, features,
                            cutoff_corr, cutoff_xcorr):
        """
        Insert a new XCORR record.
        :return: The ID of the new record
        """
        ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        names  = [ "time",  "filename",    "cutoff_corr",    "cutoff_xcorr" ]
        values = [  q(ts), q(filename), str(cutoff_corr), str(cutoff_xcorr) ]
        record_id = self.insert("records", names, values)
        print("DB: inserted record: " + record_id)
        for feature in features:
            feature_id = str(self.feature_name2id[feature])
            self.insert("features", ["record_id", "feature_id"],
                                    [ record_id ,  feature_id ])
        for study in studies:
            study_id = str(self.study_name2id[study])
            self.insert("studies", ["record_id", "study_id"],
                                   [ record_id ,  study_id ])

        return record_id

    def read_feature_names(self):
        cmd = "select rowid, name from feature_names;"
        self.cursor.execute(cmd)
        self.feature_id2name = {}
        self.feature_name2id = {}
        while True:
            row = self.cursor.fetchone()
            if row == None: break
            rowid, name = row[0:2]
            self.feature_id2name[rowid] = name
            self.feature_name2id[name]  = rowid
        return self.feature_id2name, self.feature_name2id

    def read_study_names(self):
        cmd = "select rowid, name from study_names;"
        self.cursor.execute(cmd)
        self.study_id2name = {}
        self.study_name2id = {}
        while True:
            row = self.cursor.fetchone()
            if row == None: break
            rowid, name = row[0:2]
            self.study_id2name[rowid] = name
            self.study_name2id[name]  = rowid
        return self.study_id2name, self.study_name2id

    def insert(self, table, names, values):
        """ Do a SQL insert """
        names_tpl  = sql_tuple(names)
        values_tpl = sql_tuple(values)
        cmd = "insert into %s %s values %s;" % (table, names_tpl, values_tpl)
        print("SQL: " + cmd)
        self.cursor.execute(cmd)
        rowid = str(self.cursor.lastrowid)
        return rowid

    def execute(self, cmd):
        self.cursor.execute(cmd)

    def executescript(self, cmds):
        self.cursor.executescript(cmds);

    def commit(self):
        self.conn.commit()

    def close(self):
        self.autoclose = False
        self.conn.close()

    def __del__(self):
        if not self.autoclose:
            return
        self.conn.commit()
        self.conn.close()
        print("DB auto-closed.");


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
