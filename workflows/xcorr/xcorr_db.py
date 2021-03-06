
# XCORR DB PY
# DB helper functions

import datetime
import logging
import os
import sqlite3
import sys

def setup_db(db_file):
    if 'DB' not in globals():
        rank = os.getenv('PMIX_RANK')
        print('rank %s Connecting to DB...' % rank)
        global DB
        DB = xcorr_db(db_file)
        DB.read_feature_names()
        DB.read_study_names()
    return DB

class xcorr_db:

    def __init__(self, db_file, log=False):
        """
        Sets up a wrapper around the SQL connection and cursor objects
        Also caches dicts that convert between names and ids for the
        features and studies tables
        """
        #self.conn = sqlite3.connect(db_file)
        #self.cursor = self.conn.cursor()
        self.db_file = db_file
        self.feature_id2name = None
        self.feature_name2id = None
        self.study_id2name   = None
        self.study_name2id   = None
        self.autoclose       = True
        self.logger          = None # Default
        if log:
            logging.basicConfig(format="SQL: %(message)s")
            self.logger = logging.getLogger("xcorr_db")
            self.logger.setLevel(logging.DEBUG)

    def connect(self):
        self.conn = sqlite3.connect(self.db_file)
        self.cursor = self.conn.cursor()
        self.cursor.execute("PRAGMA busy_timeout = 30000")

    # provisional for cp1 runs
    def insert_hpo_record(self, record_id):
        ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        self.connect()
        with self.conn:
            hpo_id = self.insert(table='hpos', names=['xcorr_record_id', 'time'],
                values = [str(record_id), q(ts)])
            self.commit()
        return hpo_id

    def insert_hpo_run(self, hpo_id, param_string, run_directory):
        ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        self.connect()
        with self.conn:
            run_id = self.insert(table='hpo_runs', names=['hpoid', 'params', 'run_directory', 'start'],
                values = [str(hpo_id), q(param_string), q(run_directory), q(ts)])
            self.commit()
        return run_id

    def update_hpo_run(self, run_id, result):
        ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        sql = "update hpo_runs set obj_result = ?, end = ? where runid = ?"
        self.connect()
        with self.conn:
            self.cursor.execute(sql, (result, ts, run_id))
            self.commit()

    def insert_xcorr_record(self, studies, features,
                            cutoff_corr, cutoff_xcorr):
        """
        Insert a new XCORR record.
        :return: The ID of the new record
        """
        ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        names  = [ "time",    "cutoff_corr",    "cutoff_xcorr" ]
        values = [  q(ts), str(cutoff_corr), str(cutoff_xcorr) ]

        self.connect()
        with self.conn:
            record_id = self.insert("records", names, values)
            for feature in features:
                feature_id = str(self.feature_name2id[feature])
                self.insert(table="features",
                            names=[ "record_id", "feature_id"],
                            values=[ record_id ,  feature_id ])
            for study in studies:
                study_id = str(self.study_name2id[study])
                self.insert(table="studies",
                            names=[ "record_id", "study_id"],
                            values=[ record_id ,  study_id ])
            self.commit()
        self.log("inserted record: " + record_id)
        return record_id

    def scan_features_file(self, filename):
        results = []
        with open(filename) as fp:
            while True:
                line = fp.readline()
                if line == "": break
                tokens = line.split("#")
                line = tokens[0]
                line = line.strip()
                if line == "": continue
                line = line.replace("rnaseq.", "")
                results.append(line)
        return results

    def read_feature_names(self):
        self.connect()
        with self.conn:
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
        self.connect()
        with self.conn:
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
        cmd = "insert into {} {} values {};".format(table, names_tpl, values_tpl)
        self.execute(cmd)
        rowid = str(self.cursor.lastrowid)
        return rowid

    def execute(self, cmd):
        self.log(cmd)
        self.cursor.execute(cmd)

    def executescript(self, cmds):
        self.cursor.executescript(cmds)

    def commit(self):
        self.conn.commit()

    def close(self):
        self.autoclose = False
        self.conn.close()

    def log(self, message):
        if self.logger:
            self.logger.info(message)

    def __del__(self):
        if not self.autoclose:
            return
        self.conn.commit()
        self.conn.close()
        self.log("DB auto-closed.")


def q(s):
    """ Quote the given string """
    return "'" + str(s) + "'"

def qL(L):
    """ Quote each list entry as a string """
    return map(q, L)

def qA(*args):
    """ Quote each argument as a string """
    return map(q, args)

def sql_tuple(L):
    """ Make the given list into a SQL-formatted tuple """
    result = ""
    result += "("
    result += ",".join(L)
    result += ")"
    return result
