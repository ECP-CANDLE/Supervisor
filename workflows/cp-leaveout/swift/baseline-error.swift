
/**
   BASELINE ERROR SWIFT
   Runs the given nodes in new output directory based on
   the pre-processed data in another "reference" directory
*/

import assert;
import files;
import io;
import python;
import string;
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
// Mapping from node ID to epochs, one per line
// file file_epochs = input(argv("epochs"));
int benchmark_timeout = string2int(argv("benchmark_timeout", "-1"));
int epochs_all = string2int(argv("E", "50"));
int patience = string2int(argv("P", "50"));
// == Command-line Arguments End ==

// == Environment Settings Begin ==
string model_name     = getenv("MODEL_NAME");
string exp_id         = getenv("EXPID");
string turbine_output = getenv("TURBINE_OUTPUT");
// == Environment Settings End ==

// For compatibility with obj():
global const string FRAMEWORK = "keras";

// Read file of node IDs:
string nodes_lines[] = file_lines(file_nodes);

// Read file of epochs:
// string epochs_lines[] = file_lines(file_epochs);

// // Mapping from node ID to epochs:
// string map_epochs[string];
// foreach line in epochs_lines
// {
//   tokens = split(line);
//   map_epochs[tokens[0]] = tokens[1];
// }

// Resultant output values:
string results[];

// Templated parameters for all runs as JSON.
// Some keys must be filled in later.
string params_template =
----
{
"config_file":    "uno_auc_model.txt",
"cache":          "cache/top6_auc",
"dataframe_from": "%s",
"save_weights":   "save/model.h5",
"gpus":           "0",
"epochs":         %i,
"es":             "True",
"patience":       %i,
"node":              "%s",
"use_exported_data": "%s"
}
----;

// Evaluate each parameter set
foreach node, i in nodes_lines
{
  printf("node: %s", node);
  // Fill in missing hyperparameters:
  string training_data = "%s/run/%s/topN.uno.h5" % (reference, node);
  // int epochs = string2int(map_epochs[node]);
  int epochs = epochs_all;
  string params = params_template % (dataframe_csv, epochs, patience,
                                     node, training_data);
  // NOTE: obj() is in the obj_*.swift supplied by workflow.sh
  results[i] = obj(params, node);
  assert(results[i] != "EXCEPTION", "exception in obj()!");
}
