
/** DB INIT PY
    Initialize the SQLite DB
    See db-init.py for usage
*/

create table records(
       /* use rowid for unique record id */
       time timestamp,
       filename text,
       source1 text,
       source2 text,
       /* cutoff for the correlation */
       cutoff_corr real,
       /* cutoff for the cross-correlation */
       cutoff_xcorr real
);

create table features(
       record_id integer,
       feature_id integer
);

create table feature_names(
       name text
);
