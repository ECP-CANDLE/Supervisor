
/*
  RECUR 2 SWIFT

  Simply run with: 'swift-t recur-1.swift | nl'
  Or specify the N, S values:
  'swift-t recur-1.swift -N=6 -S=6 | nl'
  for 55,986 tasks.
*/

import io;
import files;
import python;
import string;
import sys;

// Data split factor with default
N = string2int(argv("N", "2"));
// Maximum stage number with default
// (tested up to S=7, 21,844 dummy tasks)
S = string2int(argv("S", "2"));

// For compatibility with obj():
global const string FRAMEWORK = "keras";

file plan_json = input("~/plan.json");

(void v) run_stage(int N, int S, string parent, int stage,
                   int id, void block)
{
  this = parent+int2string(id);
  v = run_dummy(parent, stage, id, block);
  if (stage < S)
  {
    foreach id_child in [0:N-1]
    {
      run_stage(N, S, this, stage+1, id_child, v);
    }
  }
}

(void v) db_setup()
{
  python_persist(----
import db_cplo_init
global db_file
db_file = 'cplo.db'
db_cplo_init.main(db_file)
----,
----
'OK'
----) =>
    v = propagate();
}

(void v) run_dummy(string parent, int stage, int id, void block)
{
  json_fragment = ----
"pre_module":  "data_setup",
"post_module": "data_setup",
"plan":        "/home/wozniak/plan.json",
"dataframe_from":
    "/usb1/wozniak/CANDLE-Benchmarks-Data/top21_dataframe_8x8.csv"
----;
  if (stage == 0)
  {
    db_setup() =>
      v = propagate();
  }
  else
  {
    node = parent + "." + stage;
    json = "{\"node\": \"%s\", %s}" % (node, json_fragment);
    block =>
      printf("running obj(%s)", node) =>
      s = obj(json, node);
    v = propagate(s);
    // v = dummy(parent, stage, id, block);
  }
}

app (void v) dummy(string parent, int stage, int id, void block)
{
  "echo" ("parent='%3s'"%parent) ("stage="+stage) ("id="+id) ;
}

stage = 0;
id = 0;
run_stage(N, S, "", stage, id, propagate());
