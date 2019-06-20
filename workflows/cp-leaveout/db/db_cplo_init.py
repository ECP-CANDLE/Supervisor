
# DB CPLO INIT PY
# Initialize the SQLite DB for CP LEAVE OUT
# See db-cplo-init.sql for the table schema

import os, sys

from candle_sql import candle_sql, qA

print("READ 1")

# Hack for embedded Python:
# Cf. https://github.com/googleapis/oauth2client/issues/642
if not hasattr(sys, 'argv'):
    print("HACK")
    sys.argv  = ['placeholder']
# import yaml

print("READ 2")

def create_tables(DB, db_cplo_init_sql):
    """ Set up the tables defined in the SQL file """
    print("creating tables: " + db_cplo_init_sql)
    DB.connect()
    with open(db_cplo_init_sql) as fp:
        sqlcode = fp.read()
    DB.executescript(sqlcode)
    DB.commit()

# insert_id(argvars["id"])
# def insert_id(id):
#     global DB
#     import datetime
#     ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
#     DB.insert(table="cplo_ids",
#               names=["cplo_id","time"],
#               values=qA(id, ts))

def main(db_file):

    # Catch and print all exceptions to improve visibility of success/failure
    success = False
    try:
        with open("python-errors.txt", "a") as fp:
            fp.write("HELLO\n")
        print("candle_sql ...")
        DB = candle_sql(db_file, log=True)
        print("candle_sql ok")
        this = os.getenv("EMEWS_PROJECT_ROOT")
        db_cplo_init_sql = this + "/db/db-cplo-init.sql"
        create_tables(DB, db_cplo_init_sql)
        success = True
    except Exception as e:
        import traceback
        print(traceback.format_exc())
        with open("python-errors.txt", "a") as fp:
            fp.write(traceback.format_exc())
            fp.write("\n")

    if not success:
        print("DB: !!! INIT FAILED !!!")
        exit(1)

    print("DB: initialized successfully")

if __name__ == "__main__" and 'db_file' not in globals():
    print("NAME...")
    with open("python-errors.txt", "a") as fp:
        fp.write("__name__\n")
    import argparse
    parser = argparse.ArgumentParser(description="Setup the CPLO DB.")
    parser.add_argument("db", action="store", help="specify DB file")
    parser.add_argument("id", action="store", help="specify new CPLO ID")
    args = parser.parse_args()
    argvars = vars(args)

    db_file = argvars["db"]
    main(db_file)
    
print("READ 10")
