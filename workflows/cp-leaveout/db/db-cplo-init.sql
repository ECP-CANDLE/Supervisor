
/** DB CPLO INIT PY
    Initialize the SQLite DB for CPLO
    See db-cplo-init.py for usage
*/

PRAGMA foreign_keys = ON;

/* The main table, one row for each CPLO instance
   The CPLO ID is specified by the user and is conventionally
   the same as the EMEWS experiment ID.
*/
create table if not exists cplo_ids(
       cplo_id integer primary key,
       parent integer,
       /* creation time */
       parent integer,
       time timestamp
);

/* Each CPLO instance has multiple leaveouts defined here */
create table if not exists cplo_leaveouts(
       cplo_id integer,
       value integer,
       /* the specification of what was left out */
       name text,
       foreign key (cplo_id) references cplo_ids(cplo_id)
);
