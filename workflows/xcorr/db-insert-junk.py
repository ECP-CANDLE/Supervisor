
# DB INSERT JUNK PY
# Test SQLite DB
# See init-db.sql for the table schema

import datetime
import random
import time

from xcorr_db import xcorr_db, q

DB = xcorr_db('xcorr.db')

feature_id2name, feature_name2id = DB.read_feature_names()
study_id2name,   study_name2id   = DB.read_study_names()

feature_names = feature_name2id.keys()
study_names   = study_name2id  .keys()

for i in range(1,4):
    filename = "file-%i.csv" % i
    cutoff_corr = 0.9
    cutoff_xcorr = 0.8
    features = [ feature for feature in feature_names
                 if random.randint(0,300) == 0 ]
    studies  = [ study   for study   in study_names
                 if random.randint(0,1) == 0 ]
    # print(features)
    record = (filename,features,cutoff_corr,cutoff_xcorr)
    DB.insert_xcorr_record(filename, studies, features,
                           cutoff_corr, cutoff_xcorr)
