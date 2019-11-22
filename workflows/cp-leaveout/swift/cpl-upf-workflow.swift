
/*
  CPL-UPF-WORKFLOW.SWIFT

  run with: 'swift-t workflow.swift <FILE SETTINGS>'

  FILE SETTINGS:
  These are mandatory:
  --plan_json=<FILE>     : The JSON plan for topN_to_uno
  --dataframe_csv=<FILE> : The CSV data file for topN_to_uno
  --db_file=<FILE>       : The SQLite DB file
  --benchmark_data=<DIR> : Location of Bencharks/Pilot1/Uno.
                           Used by data_setup to set softlinks to
                           Uno cache and uno_auc_model.txt
  --f                    : The UPF file
  --parent_stage_directory: The root experiment directory for the this runs parent stage.
                            Child stages will look here for initial model weights by appending
                            run/<parent_node_id> to this parent directory

*/

import assert;
import io;
import files;
import python;
import string;
import sys;
import plangen;
import unix;

// BEGIN WORKFLOW ARGUMENTS
int stage = string2int(argv("stage"));

string runtype;
if (argv_contains("r"))
{
  runtype = "plangen.RunType.RESTART";
}
else
{
  runtype = "plangen.RunType.RUN_ALL";
}

file upf = input(argv("f"));
string plan_json      = argv("plan_json");
string dataframe_csv  = argv("dataframe_csv");
string db_file        = argv("db_file");
string benchmark_data = argv("benchmark_data");
string parent_stage_directory = argv("parent_stage_directory", "");

string turbine_output = getenv("TURBINE_OUTPUT");

# These 3 are used in obj_py so we need to initialize them here
int    benchmark_timeout = toint(getenv("BENCHMARK_TIMEOUT"));
string model_name     = getenv("MODEL_NAME");
string exp_id         = getenv("EXPID");

// initial epochs
int epochs = 6;
// END WORKFLOW ARGUMENTS

// For compatibility with obj():
global const string FRAMEWORK = "keras";

(string h_json) read_history(string node) {
  string history_file  = "%s/run/%s/history.txt" % (turbine_output, node);
  if (file_exists(history_file)) {
    h_json = read(input(history_file));
  } else {
    h_json = "{}";
  }
}

/** RUN SINGLE: Set up and run a single model via obj(), plus the SQL ops */
(string r, string ins) run_single(string node, string plan_id)
{
  json_fragment = make_json_fragment(node);
  json = "{\"node\": \"%s\", %s}" % (node, json_fragment);
  json2 = replace_all(json, "\n", " ", 0);
  db_start_result = plangen_start(db_file, plan_json, node, plan_id, runtype);
  ins = json2;
  assert(db_start_result != "EXCEPTION", "Exception in plangen_start()!");
  if (db_start_result == "0") {
    r = obj(json2, node) =>
      string hist_json = read_history(node);
      db_stop_result = plangen_stop(db_file, node, plan_id, hist_json) =>
    assert(db_stop_result != "EXCEPTION", "Exception in plangen_stop()!") =>                                   printf("stop_subplan result: %s", db_stop_result);
  } else {
    printf("plan node already marked complete: %s result=%s", node, db_start_result) =>
      r = "error";
  }
}

/** MAKE JSON FRAGMENT: Construct the JSON parameter fragment for the model */
(string result) make_json_fragment(string this)
{
    int this_ep;
    if (stage > 1)
    {
      this_ep = max_integer(epochs %/ float2int(pow_integer(2, (stage - 1))), 1);
    }
    else
    {
      this_ep = epochs;
    }
    //"pre_module":     "data_setup",
    json_fragment = ----
"pre_module":     "data_setup",
"post_module":    "data_setup",
"plan":           "%s",
"config_file":    "uno_auc_model.txt",
"cache":          "cache/top6_auc",
"dataframe_from": "%s",
"save_weights":   "model.h5",
"gpus": "0",
"epochs": %i,
"use_exported_data": "topN.uno.h5",
"benchmark_data": "%s"
---- %
(plan_json, dataframe_csv, this_ep, benchmark_data);
  if (stage > 1)
  {
    n = strlen(this);
    parent = substring(this, 0, n-2);
    result = json_fragment + ----
,
"initial_weights": "%s/run/%s/model.h5"
      ---- % (parent_stage_directory, parent);
  }
  else
  {
    result = json_fragment;
  }
}

printf("CP LEAVEOUT UPF WORKFLOW START- UPF: %s, STAGE: %i", filename(upf), stage);

(void o) write_lines(string lines[], string f) {
  string lines_string = join(lines,"\n");
  fname = "%s/%s" % (turbine_output, f);
  file out <fname> = write(lines_string) =>
  o = propagate();
}

main() {
  string check = check_plangen() =>
    printf("python result: import plangen: '%s'", check) =>
    assert(check == "OK", "could not import plangen, check PYTHONPATH!");

  string plan_id;

  if (stage > 1) {
    file pif = input("%s/plan_id.txt" % parent_stage_directory);
    file parent_db = input("%s/%s" % (parent_stage_directory, basename_string(db_file)));
    file dbf <db_file> = cp(parent_db) =>
    plan_id = trim(read(pif));
  } else {
    plan_id = init_plangen(db_file, plan_json, runtype);
  }

  // string plan_id = init_plangen(db_file, plan_json, runtype);
  printf("DB plan_id: %s", plan_id) =>
  assert(plan_id != "EXCEPTION", "Plan prep failed!");
  // If the plan already exists and we are not doing a restart, abort
  assert(plan_id != "-1", "Plan already exists!");

  // Read unrolled parameter file
  string upf_lines[] = file_lines(upf);

  // Resultant output values:
  string results[];
  //string inputs[];

  //string plan_id = "1";

  // Evaluate each parameter set
  foreach params,i in upf_lines
  {
    // printf("params: %s", params);
    result, inputs = run_single(params, plan_id);
    results[i] = "%s|%s|%s" % (params, replace_all(inputs, "\n", " ", 0), result);
    //inputs[i] = "%i|%s" % (i, inputs);
  }
  // Join all result values into one big semicolon-delimited string
  // string result = join(results, ";") =>
  file out<"%s/plan_id.txt" % turbine_output> = write("%s\n" % plan_id);
  write_lines(results, "results.txt") => 
  printf("CP LEAVEOUT WORKFLOW: RESULTS: COMPLETE");
}
