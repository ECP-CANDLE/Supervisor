
/** DB HPO INIT PY
    Initialize the SQLite DB for HPO
    See db-hpo-init.py for usage
*/

/* The main table, one row for each HPO instance */
create table if not exists hpo_ids(
       hpo_id integer primary key,
       /* creation time */
       time timestamp
);

create table if not exists hpo_hyperparam_defns(
       rowid integer primary key,
       hpo_id integer,
       name text
);

/* For each HPO instance there is a set of param_ids .
   Each categorical param_id has a set of values in this table */
create table if not exists hpo_hyperparam_values(
       /* ID in table hpo_ids */
       hpo_id integer,
       param_id integer,
       value text
);

create table if not exists hpo_samples(
       rowid integer primary key,
       /* creation time */
       creation timestamp,
       /* completion time */
       completion timestamp,
       /* params: for categoricals, a comma-separated list of param_ids */
       hyperparams text,
       value real
);
