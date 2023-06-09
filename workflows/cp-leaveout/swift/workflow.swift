
/*
  WORKFLOW SWIFT

  Simply run with: 'swift-t workflow.swift <FILE SETTINGS>'
  Or specify the N, S values:
  'swift-t workflow.swift -N=4 -S=6 <FILE SETTINGS>'
  for ### tasks.

  Flags:
  -N : Number of nodes per stage (see default in code)
  -S : Number of stages          (see default in code)
  -E : Number of epochs          (see default in Benchmark)
  -P : Early stopping patience   (see default in code)
  -r : Use RunType.RESTART, default is RunType.RUN_ALL
       RUN_ALL means this is a fresh run with no prior results

  FILE SETTINGS:
  These are mandatory:
  --plan_json=<FILE>     : The JSON plan for topN_to_uno
  --dataframe_csv=<FILE> : The CSV data file for topN_to_uno
  --db_file=<FILE>       : The SQLite DB file
  --benchmark_data=<DIR> : Used by data_setup to set softlinks to
                           Uno cache and uno_auc_model.txt

  NOTE: "token" variables are used to ensure that children do
        not run before their parents
  NOTE: This workflow has some complex Python Exception handling
        code that will be pushed into Swift/T for conciseness...
  NOTE: On Summit, you have to use sys.stdout.flush() after
        Python output on stdout

  RESTART EXAMPLE:
  test/test-512.sh summit EXP003 flat -r -N=4 -S=6 -E=5 -P=5
*/

import assert;
import io;
import files;
import math;
import python;
import string;
import sys;

import candle_utils;
import plangen_2;

report_env();

// BEGIN WORKFLOW ARGUMENTS
// Data split factor with default
int N;
N_s = argv("N", "2");
if (strlen(N_s) > 0)
{
  N = string2int(N_s);
}
else
{
  N = 0;
}
// Maximum stage number with default
int S;
S_s = argv("S", "2");
assert(strlen(S_s) > 0, "Set argument S with -S=<S>") =>
  S = string2int(S_s);
string runtype;
if (argv_contains("r"))
{
  runtype = "plangen.RunType.RESTART";
}
else
{
  runtype = "plangen.RunType.RUN_ALL";
}
E_s = argv("E", "50");
assert(strlen(E_s) > 0, "workflow.swift: you must provide an argument to -E");
int max_epochs = string2int(E_s); // epochs=20 is just under 2h on Summit.
P_s = argv("P", "10");
assert(strlen(P_s) > 0, "workflow.swift: you must provide an argument to -P");
int early_stopping = string2int(P_s);
string plan_json      = argv("plan_json");
string dataframe_csv  = argv("dataframe_csv");
string db_file        = argv("db_file");
string user           = argv("user", "NONE");  // for Summit NVME
string benchmark_data = argv("benchmark_data");
int    epoch_mode       = string2int(argv("epoch_mode", "1"));
int    benchmark_timeout = string2int(argv("benchmark_timeout", "-1"));
string model_name     = getenv("MODEL_NAME");
string exp_id         = getenv("EXPID");
string turbine_output = getenv("TURBINE_OUTPUT");
// END WORKFLOW ARGUMENTS

printf("plangen: runtype:" + runtype);
printf("benchmark_data: " + benchmark_data);

// For compatibility with obj():
global const string FRAMEWORK = "keras";

/**
   RUN STAGE: A recursive function that manages the stage dependencies
   token_parent: Blocks progress until the parent node is done
   parent:       The parent node,  e.g., "1.2.3"
   this:         The current node, e.g., "1.2.3.4"
*/
(void v)
run_stage(string db_file, string plan_id, string runtype,
          void token_parent, int stage, string parent, string this)
{
  // printf("stage: %i parent: %s this: %s", stage, parent, this);
  // Run the model
  void token_this = run_single(plan_id, token_parent, stage,
                               parent, this);

  if (stage < S)
  {
    // Recurse to the child stages
    foreach child in [1:N]
    {
      run_stage(db_file, plan_id, runtype,
                token_this, stage+1,
                this,
                "%s.%i" % (this, child)
                ); // N, S,
    }
  }
  v = propagate();
}

/**
   RUN SINGLE: Set up and run a single model via obj(), plus the SQL ops
   token: Block on token so that this node does not run until the
   parent is complete.
   stage:  The current stage, e.g., 4
   parent: The parent node,   e.g., "1.2.3"
   this:   The current node,  e.g., "1.2.3.4"
*/
(void v) run_single(string plan_id, void token, int stage,
                    string parent, string this)
{
  if (stage == 0)
  {
    v = propagate();
  }
  else
  {
    json_fragment = make_json_fragment(parent, this, stage);
    json = "{\"node\": \"%s\", %s}" % (this, json_fragment);
    token =>
      printf("run_single(): running candle_model_train(%s)", this) =>
      // Insert the model run into the DB
      result1 = plangen_start(this, plan_id);
    assert(result1 != "EXCEPTION", "Exception in plangen_start()!");
    if (result1 == "0")
    {
      // Run the model
      model_result = candle_model_train(json, exp_id, this, model_name);
      printf("run_single(): completed: node: '%s' result: '%s'",
             this, model_result);
      // Update the DB to complete the model run
      string result2;
      if (model_result != "RUN_EXCEPTION")
      {
        result2 = plangen_stop(this, plan_id);
      }
      else
      {
        result2 = "RETRY";
      }
      assert(model_result != "", "Error in obj(): result is empty!");
      assert(model_result != "EXCEPTION", "Exception in obj()!");
      assert(result2 != "EXCEPTION", "Exception in plangen_stop()!");
      printf("run_single(): stop_subplan result: '%s'", result2);
      v = propagate(model_result);
    }
    else // result1 != 0
    {
      printf("run_single(): plan node already marked complete: " +
             "%s result=%s", this, result1) =>
        v = propagate();
    }
  }
}

/** MAKE JSON FRAGMENT: Construct the JSON parameter fragment for the model */
(string result) make_json_fragment(string parent, string this, int stage)
{
  int epochs = compute_epochs(stage);
  json_fragment = ----
"pre_module":        "data_setup",
"post_module":       "data_setup",
"plan":              "%s",
"config_file":       "uno_auc_model.txt",
"cache":             "cache/top6_auc",
"user":              "%s",
"dataframe_from":    "%s",
"save_weights":      "save/model.h5",
"gpus":              "0",
"epochs":            %i,
"es":                "True",
"early_stopping":    %i,
"experiment_id":     "%s",
"run_id":            "%s",
"use_exported_data": "topN.uno.h5",
"benchmark_data":    "%s"
---- %
(plan_json, user, dataframe_csv, epochs, early_stopping, exp_id, this, benchmark_data);
  if (stage > 1)
  {
    result = json_fragment + ----
,
"initial_weights": "../%s/save/model.h5"
---- % parent;
  }
  else
  {
    result = json_fragment;
  }
}

printf("CP LEAVEOUT WORKFLOW: START: N=%i S=%i", N, S);

// First: simple test that we can import plangen
check = plangen_check();
assert(check == "OK", "could not import plangen, check PYTHONPATH!");

plan_id = plangen_prep(db_file, plan_json, "NOTHING");
printf("DB plan_id: %s", plan_id);
assert(plan_id != "EXCEPTION", "Plan prep failed!");

// If the plan already exists and we are not doing a restart, abort
assert(plan_id != "-1", "Plan already exists!");

// Kickoff the workflow
stage = 0;
run_stage(db_file, plan_id, runtype,
          propagate(), stage, "", "1");
