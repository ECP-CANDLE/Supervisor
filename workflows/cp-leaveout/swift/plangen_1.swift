
/*
  PLANGEN 1 SWIFT
  An early attempt at plangen with FS locks - did not work.
*/

import python;

pragma worktypedef DB;

@dispatch=DB
  (string output) python_db(string code, string expr)
"turbine" "0.1.0"
  [ "set <<output>> [ turbine::python 1 1 <<code>> <<expr>> ]" ];


(string check) check_plangen() {
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

(string plan_id) init_plangen(string db_file, string plan_json, string runtype) {
    plan_id = python_db(
----
import sys, traceback
import plangen
try:
    result = str(plangen.plan_prep('%s', '%s', %s))
except Exception as e:
    info = sys.exc_info()
    s = traceback.format_tb(info[2])
    print(str(e) + ' ... \\n' + ''.join(s))
    sys.stdout.flush()
    result = 'EXCEPTION'
---- % (db_file, plan_json, runtype),
    "result");
}

(string result) plangen_start(string db_file, string plan_json, string node, string plan_id, string runtype) {
  result = python_db(
----
import fcntl, sys, traceback
import plangen
try:
    fp = open("lock", "w+")
    fcntl.flock(fp, fcntl.LOCK_EX)
    result = str(plangen.start_subplan('%s', '%s', %s, '%s', %s))
    fcntl.flock(fp, fcntl.LOCK_UN)
    fp.close()
except Exception as e:
    info = sys.exc_info()
    s = traceback.format_tb(info[2])
    print(str(e) + ' ... \\n' + ''.join(s))
    sys.stdout.flush()
    result = "EXCEPTION"
----  % (db_file, plan_json, plan_id, node, runtype),
    "result");
}

(string result) plangen_stop(string db_file, string node, string plan_id, string history_json)
{
  result = python_db(
----
import plangen
import json
import fcntl, sys, traceback
try:
    fp = open("lock", "w+")
    fcntl.flock(fp, fcntl.LOCK_EX)
    history_dict = json.loads("""%s""")
    result = str(plangen.stop_subplan('%s', '%s', '%s', history_dict))
    fcntl.flock(fp, fcntl.LOCK_UN)
    fp.close()
except Exception as e:
    info = sys.exc_info()
    s = traceback.format_tb(info[2])
    print(str(e) + ' ... \\n' + ''.join(s))
    sys.stdout.flush()
    result = 'EXCEPTION'
---- % (history_json, db_file, plan_id, node),
      "result");
}
