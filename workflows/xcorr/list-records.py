# LIST RECORDS PY
# List all the records in the DB and their metadata

from record import Record
from xcorr_db import q, xcorr_db

DB = xcorr_db("xcorr.db")

feature_id2name, feature_name2id = DB.read_feature_names()
study_id2name, study_name2id = DB.read_study_names()

# Main list of records
records = []

# Read all the record IDs in the DB:
record_ids = []
DB.execute("select rowid from records;")
while True:
    row = DB.cursor.fetchone()
    if row == None:
        break
    record_ids.append(row[0])

# Read the record data
for record_id in record_ids:
    # Read basic metadata for record
    record = Record()
    DB.execute("select * from records where rowid == %i;" % record_id)
    row = DB.cursor.fetchone()
    record.scan(row)

    # Read features for record
    DB.execute("select * from features where record_id == %i;" % record_id)
    while True:
        row = DB.cursor.fetchone()
        if row == None:
            break
        feature = feature_id2name[row[1]]
        record.features.append(feature)

    # Read studies for record
    DB.execute("select * from studies where record_id == %i;" % record_id)
    while True:
        row = DB.cursor.fetchone()
        if row == None:
            break
        study = study_id2name[row[1]]
        record.studies.append(study)

    # Add the record to the main list
    records.append(record)

# Print the record data
for record in records:
    record.print()
    print("")
