
/*
  WORKFLOW SWIFT

  Simply run with: 'swift-t workflow.swift'
  Or specify the N, S values:
  'swift-t workflow.swift -N=6 -S=6'
  for 55,986 tasks.
  Flags:
  -N : Number of nodes per stage
  -S : Number of stages
  -r : Use RunType.RESTART, default is RunType.RUN_ALL
  --db_file : The SQLite DB file
*/

import assert;
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
string runtype;
if (argv_contains("r"))
{
  runtype = "plangen.RunType.RESTART";
}
else
{
  runtype = "plangen.RunType.RUN_ALL";
}
string db_file = argv("db_file");

// For compatibility with obj():
global const string FRAMEWORK = "keras";

// file plan_json = input("/home/wozniak/plan.json");
file plan_json =
  input("/home/wozniak/proj/SV.develop/workflows/cp-leaveout/plangen_cell8-p2_drug8-p2.json");

(void v)
run_stage(int N, int S, string this, int stage, void block,
          string plan_id, string db_file, string runtype)
{

  printf("stage: %i this: %s", stage, this);
  // Run the model
  void parent = run_single(this, stage, block, plan_id);

  if (stage < S)
  {
    foreach id_child in [1:N]
    {
      run_stage(N, S, this+"."+id_child, stage+1, parent,
                plan_id, db_file, runtype);
    }
  }
  v = propagate();
}

(void v) run_single(string node, int stage, void block, string plan_id)
{
  json_fragment = make_json_fragment(node, stage);
  if (stage == 0)
  {
    // db_setup() => // cf. junk.swift
    v = propagate();
  }
  else
  {
    json = "{\"node\": \"%s\", %s}" % (node, json_fragment);
    block =>
      printf("running obj(%s)", node) =>
      // Insert the model run into the DB
      code = python_persist("import plangen",
                            "str(plangen.start_subplan('%s', '%s', %s, '%s', %s))" %
                            (db_file, filename(plan_json), plan_id, node, runtype));
    if (code == "0")
    {
      // Run the model
      s = obj(json, node) =>
        printf("completed: node: " + node) =>
        // Update the DB to complete the model run
        python_persist("import plangen",
                       "str(plangen.stop_subplan('%s', '%s', '%s', {}))" %
                       (db_file, plan_id, node));
      v = propagate(s);
    }
    else
    {
      printf("plan node already marked complete: " + node) =>
        v = propagate();
    }
    // v = dummy(parent, stage, id, block); // cf. junk.swift
  }
}

(string result) make_json_fragment(string this, int stage)
{
    json_fragment = ----
"pre_module":  "data_setup",
"post_module": "data_setup",
"plan":        "/home/wozniak/plan.json",
"config_file": "uno_auc_model.txt",
"cache":       "cache/top6_auc",
"dataframe_from":
    "/usb1/wozniak/CANDLE-Benchmarks-Data/top21_dataframe_8x8.csv",
"save_weights": "model.h5"
----;
  if (stage > 1)
  {
    n = strlen(this);
    parent = substring(this, 0, n-2);
    result = json_fragment + ----
,
"initial_weights": "../%s/model.h5"
---- % parent;
  }
  else
  {
    result = json_fragment;
  }
}

plan_id = python_persist("import plangen",
                         "str(plangen.plan_prep('%s', '%s', %s))" %
                         (db_file, filename(plan_json), runtype));
printf("DB plan_id: %s", plan_id);

// python("print('hi')");
assert(plan_id != "-1", "Plan already exists!");

stage = 0;
run_stage(N, S, "1", stage, propagate(), plan_id, db_file, runtype) =>
  printf("RESULTS: COMPLETE");
