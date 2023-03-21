
/**
   CMP-CV WORKFLOW.SWIFT
*/

import assert;
import io;
import json;
import files;
import string;
import sys;

import candle_utils;
// report_env();

string FRAMEWORK = "keras";

// Scan command line
// file   plan = input(argv("plan"));
file   model_file = input(argv("models"));
file   gparams_file = input(argv("gparams"));
int    benchmark_timeout = string2int(argv("benchmark_timeout", "-1"));

string expid          = getenv("EXPID");
string turbine_output = getenv("TURBINE_OUTPUT");

// Report some key facts:
printf("CMP-CV: %s", filename(model_file));
system1("date \"WORKFLOW START: +%Y-%m-%d %H:%M\"");

// Read unrolled parameter file
// string plan_lines[] = file_lines(plan);
string model_lines[] = file_lines(model_file);

string gparams_lines[] = file_lines(gparams_file);

// Resultant output values:
string results[];
// string run_ids[];

compare(string exp_id, string run_id)
{
  python_persist("import compare",
                 "compare.compare(\"%s\", \"%s\")") % (exp_id, run_id));
}

// Evaluate each parameter set
foreach model, i in model_lines
{
  foreach gparam, j in gparams_lines
  {
    run_id = i*1000000 + j;

    // printf("model: %s", model);
    m = "\"model_name\": \"%s\"" % model;

    gparams = replace(gparam, "MORE_PARAMS", m, 0);
    printf(gparams);
    results[run_id] = obj(params, expid, runid) =>
      compare(exp_id, run_id);

    // assert(results[i] != "EXCEPTION", "exception in obj()!");
  }
}

// // Join all result values into one big semicolon-delimited string
// string result = join(run_ids, ";");
// // and print it
// printf("WORKFLOW RESULT: " + result);
