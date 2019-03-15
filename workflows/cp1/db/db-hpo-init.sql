
/** DB HPO INIT PY
    Initialize the SQLite DB for HPO
    See db-hpo-init.py for usage
*/

PRAGMA foreign_keys = ON;

/* The main table, one row for each HPO instance
   The HPO ID is specified by the user and is conventionally
   the same as the EMEWS experiment ID.
*/
create table if not exists hpo_ids(
       hpo_id integer primary key,
       /* creation time */
       time timestamp
);

/* Each HPO instance has multiple hyperparameters defined here */
create table if not exists hpo_hyperparam_defns(
       param_id integer primary key,
       /* reference to table hpo_ids */
       hpo_id integer,
       /* the name of the hyperparameter */
       name text,
       foreign key (hpo_id) references hpo_ids(hpo_id)
);

/* For each HPO instance there is a set of param_ids .
   Each categorical param_id has a set of values in this table */
create table if not exists hpo_hyperparam_values(
       value_id integer primary key,
       /* ID in table hpo_hyperparam_defns */
       param_id integer,
       /* one of the possible valid values for this param_id */
       value text,
       foreign key (param_id) references hpo_hyperparam_defns(param_id)
);

create table if not exists hpo_samples(
       /* ID in table hpo_ids */
       hpo_id integer,
       /* creation time */
       creation timestamp,
       /* completion time */
       completion timestamp,
       /* params: for categoricals, a comma-separated list of value_ids */
       hyperparams text,
       /* the sample value, e.g., val_loss */
       value real
);
