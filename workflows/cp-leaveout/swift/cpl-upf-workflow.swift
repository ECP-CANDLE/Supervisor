
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

// initial epochs
int epochs = 6;
// END WORKFLOW ARGUMENTS

// For compatibility with obj():
global const string FRAMEWORK = "keras";


/** RUN SINGLE: Set up and run a single model via obj(), plus the SQL ops */
(string r, string ins) run_single(string node, string plan_id)
{
  json_fragment = make_json_fragment(node);  
  json = "{\"node\": \"%s\", %s}" % (node, json_fragment);
  // printf("JSON PARAMS: %s", json);
  r = obj(json, node);
  ins = json;
    
  // TODO: Add this DB stuff back-in when necessary
  // printf("running obj(%s)", node) =>
  // // Insert the model run into the DB
  // result1 = "0"; // plangen_start(node, plan_id);
  // assert(result1 != "EXCEPTION", "Exception in plangen_start()!");
  // if (result1 == "0")
  // {
  //   // Run the model
  //   s = obj(json, node) =>
  //   printf("completed: node: " + node) =>
  //   // Update the DB to complete the model run
  //   result2 = "0"; // plangen_stop(node, plan_id);
  //   assert(result2 != "EXCEPTION", "Exception in plangen_stop()!");
  //   printf("stop_subplan result: %s", result2);
  // }
  // else
  // {
  //   printf("plan node already marked complete: %s result=%s", node, result1) =>
  //     s = "ERROR";
  // }
}

// (string result) plangen_start(string node, string plan_id)
// {
//   result = python_persist(
// ----
// import fcntl, sys, traceback
// import plangen
// try:
//     fp = open("lock", "w+")
//     fcntl.flock(fp, fcntl.LOCK_EX)
//     result = str(plangen.start_subplan('%s', '%s', %s, '%s', %s))
//     fcntl.flock(fp, fcntl.LOCK_UN)
//     fp.close()
// except Exception as e:
//     info = sys.exc_info()
//     s = traceback.format_tb(info[2])
//     print(str(e) + ' ... \\n' + ''.join(s))
//     sys.stdout.flush()
//     result = "EXCEPTION"
// ----  % (db_file, plan_json, plan_id, node, runtype),
//     "result");
// }

// (string result) plangen_stop(string node, string plan_id)
// {
//   result = python_persist(
// ----
// import plangen
// import fcntl, sys, traceback
// try:
//     fp = open("lock", "w+")
//     fcntl.flock(fp, fcntl.LOCK_EX)
//     result = str(plangen.stop_subplan('%s', '%s', '%s', {}))
//     fcntl.flock(fp, fcntl.LOCK_UN)
//     fp.close()
// except Exception as e:
//     info = sys.exc_info()
//     s = traceback.format_tb(info[2])
//     print(str(e) + ' ... \\n' + ''.join(s))
//     sys.stdout.flush()
//     result = 'EXCEPTION'
// ---- % (db_file, plan_id, node),
//       "result");
// }

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

// TODO: Can't run this with swift because no numpy in the embedded python
// Uncomment when proper Python available

// First: simple test that we can import plangen
// check = python_persist(----
// try:
//     import plangen
//     result = 'OK'
// except Exception as e:
//     result = str(e)
// ----,
// "result");
// printf("python result: import plangen: '%s'", check) =>
//   assert(check == "OK", "could not import plangen, check PYTHONPATH!");

// // Initialize the DB
// plan_id = python_persist(
// ----
// import sys, traceback
// import plangen
// try:
//     result = str(plangen.plan_prep('%s', '%s', %s))
// except Exception as e:
//     info = sys.exc_info()
//     s = traceback.format_tb(info[2])
//     print(str(e) + ' ... \\n' + ''.join(s))
//     sys.stdout.flush()
//     result = 'EXCEPTION'
// ---- % (db_file, plan_json, runtype),
// "result");
// printf("DB plan_id: %s", plan_id);
// assert(plan_id != "EXCEPTION", "Plan prep failed!");

// // If the plan already exists and we are not doing a restart, abort
// assert(plan_id != "-1", "Plan already exists!");


(void o) write_lines(string lines[], string f) {
  string lines_string = join(lines,"\n");
  fname = "%s/%s" % (turbine_output, f);
  file out <fname> = write(lines_string) =>
  o = propagate();
}

main() {
  // Read unrolled parameter file
  string upf_lines[] = file_lines(upf);

  // Resultant output values:
  string results[];
  //string inputs[];

  string plan_id = "1";

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
  write_lines(results, "results.txt") =>
  printf("CP LEAVEOUT WORKFLOW: RESULTS: COMPLETE");
}
