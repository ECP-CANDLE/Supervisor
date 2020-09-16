
/**
   BASELINE ERROR SWIFT
   Runs the given nodes in new output directory based on
   the pre-processed data in another "reference" directory
*/

import assert;
import files;
import io;
import python;
import sys;

import candle_utils;
report_env();

// == Command-line Arguments Begin ==
// The big feather file or CSV
string dataframe_csv  = argv("dataframe_csv");
// Actual CP workflow output directory to use for data sources:
string reference = argv("reference");
// List of node IDs, one per line
file file_nodes = input(argv("nodes"));
int benchmark_timeout = string2int(argv("benchmark_timeout", "-1"));
// == Command-line Arguments End ==

// == Environment Settings Begin ==
string model_name     = getenv("MODEL_NAME");
string exp_id         = getenv("EXPID");
string turbine_output = getenv("TURBINE_OUTPUT");
// == Environment Settings End ==

// Read file of node IDs
string lines[] = file_lines(file_nodes);

// Resultant output values:
string results[];

// Basic parameters for all runs as JSON.
// Keys node and use_exported_data must be filled in later.
string params_basic =
----
{  
"config_file":    "uno_auc_model.txt",
"cache":          "cache/top6_auc",
"dataframe_from": "%s",
"save_weights":   "save/model.h5",
"gpus":           "0",
"epochs":         50,
"es":             "True",
"node":              "%s",
"use_exported_data": "%s"
}
----;

// Evaluate each parameter set
foreach node, i in lines
{
  printf("node: %s", node);
  // Fill in missing hyperparameters:
  string training_data = "%s/run/%s/topN.uno.h5" % (reference, node);
  string params = params_basic % (dataframe_csv, node, training_data);
  // NOTE: obj() is in the obj_*.swift supplied by workflow.sh
  results[i] = obj(params, node);
  assert(results[i] != "EXCEPTION", "exception in obj()!");
}
