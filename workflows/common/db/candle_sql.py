
import datetime
import logging
import os
import sqlite3
import sys

def setup_db(db_file):
    """
        Convenience function to use from Swift/T
       """
    if 'DB' not in globals():
        rank = os.getenv('PMIX_RANK')
        print('rank %s Connecting to DB...' % rank)
        global DB
        DB = candle_sql(db_file)
    return DB

class candle_sql:

    def __init__(self, db_file, log=False):
        """
        Sets up a wrapper around the SQL connection and cursor objects
        Also caches dicts that convert between names and ids for the
        features and studies tables
        """
        #self.conn = sqlite3.connect(db_file)
        #self.cursor = self.conn.cursor()
        self.db_file = db_file
        self.autoclose       = True
        self.logger          = None # Default
        if log:
            logging.basicConfig(format="SQL: %(message)s")
            self.logger = logging.getLogger("candle_sql")
            self.logger.setLevel(logging.DEBUG)

    def connect(self):
        self.conn = sqlite3.connect(self.db_file)
        self.cursor = self.conn.cursor()
        self.cursor.execute("PRAGMA busy_timeout = 30000")

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
