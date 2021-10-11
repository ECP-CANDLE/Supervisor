
/*
  PLANGEN 2 SWIFT
  Currently working version for Challenge Problem Uno
*/

// This DB configuration and python_db() function will put all
// calls to python_db() on rank DB corresponding to
// environment variable TURBINE_DB_WORKERS:

// Use plangen from Supervisor!

pragma worktypedef DB;

@dispatch=DB
(string output) python_db(string code, string expr="repr(0)")
"turbine" "0.1.0"
 [ "set <<output>> [ turbine::python 1 1 <<code>> <<expr>> ]" ];

// Simply use python_db() to log the DB rank:
python_db(
----
import os, sys
print("This rank is the DB rank: %s" % os.getenv("ADLB_RANK_SELF"))
sys.stdout.flush()
----
);

(string check) plangen_check() {
    // Simple test that we can import plangen
    check = python_db(----
try:
    import plangen
    result = 'OK'
except Exception as e:
    result = str(e)
    ----,
    "result");
}

(string result) plangen_prep(string db_file, string plan_json, string runtype)
{
// Initialize the DB
result = python_persist(
----
import sys, traceback
import plangen
try:
    result = str(plangen.plan_prep('%s', '%s', '%s'))
except Exception as e:
    info = sys.exc_info()
    s = traceback.format_tb(info[2])
    print(str(e) + ' ... \\n' + ''.join(s))
    sys.stdout.flush()
    result = 'EXCEPTION'
---- % (db_file, plan_json, runtype),
"result");
}

(string result) plangen_start(string node, string plan_id)
{
  result = python_db(
----
import sys, traceback
import plangen
try:
    result = str(plangen.start_subplan('%s', '%s', %s, '%s', %s))
except Exception as e:
    info = sys.exc_info()
    s = traceback.format_tb(info[2])
    print('EXCEPTION in plangen_start()\\n' +
          str(e) + ' ... \\n' + ''.join(s))
    sys.stdout.flush()
    result = "EXCEPTION"
----  % (db_file, plan_json, plan_id, node, runtype),
    "result");
}

(string result) plangen_stop(string node, string plan_id)
{
  result = python_db(
----
import plangen
import fcntl, sys, traceback
try:
    result = str(plangen.stop_subplan('%s', '%s', '%s', {}))
except Exception as e:
    info = sys.exc_info()
    s = traceback.format_tb(info[2])
    sys.stdout.write('EXCEPTION in plangen_stop()\\n' +
                     str(e) + ' ... \\n' + ''.join(s) + '\\n')
    sys.stdout.flush()
    result = 'EXCEPTION'
---- % (db_file, plan_id, node),
      "result");
}
