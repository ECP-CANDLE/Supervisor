
/** DB INIT PY
    Initialize the SQLite DB
    See db-init.py for usage
*/

/* The main table, one row for each training run */
create table records(
       /* use rowid for unique record id */
       time timestamp,
       filename text,
       study1 text,
       study2 text,
       /* cutoff for the correlation */
       cutoff_corr real,
       /* cutoff for the cross-correlation */
       cutoff_xcorr real
);


/* A given record will have multiple entries in this table,
   one for each feature used
*/
create table features(
       record_id integer, /* the rowid in table records */
       feature_id integer /* the rowid in table feature_names */
);

/* Maps feature IDs (the rowid) to feature names */
create table feature_names(
       /* use rowid for unique record id */
       name text
);
