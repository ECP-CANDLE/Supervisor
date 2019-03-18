
/** DB INIT PY
    Initialize the SQLite DB
    See db-init.py for usage
*/

/* The main table, one row for each training run */
create table if not exists records(
       rowid integer primary key,
       time timestamp,
       /* cutoff for the correlation */
       cutoff_corr integer,
       /* cutoff for the cross-correlation */
       cutoff_xcorr integer
);

/* A given record will have multiple entries in this table,
   one for each feature used
*/
create table if not exists features(
       record_id  integer, /* the rowid in table records */
       feature_id integer  /* the rowid in table feature_names */
);

/* A given record will have multiple entries in this table,
   one for each study used
*/
create table if not exists studies(
       record_id integer, /* the rowid in table records */
       study_id  integer  /* the rowid in table study_names */
);

/* Maps feature IDs (the rowid) to feature names */
create table if not exists feature_names(
       rowid integer primary key,
       name text
);

/* Maps study IDs (the rowid) to study names */
create table if not exists study_names(
       rowid integer primary key,
       name text
);
