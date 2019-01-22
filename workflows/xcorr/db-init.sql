
/** DB INIT PY
    Initialize the SQLite DB
    See db-init.py for usage
*/

create table records(
       /* use rowid for unique record id */
       time timestamp,
       metadata varchar(1024));
