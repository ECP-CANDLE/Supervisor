
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

string FRAMEWORK = "pytorch";

// Scan command line
// file   plan = input(argv("plan"));
file model_file = input(argv("models"));
file gparams_file = input(argv("gparams"));
int  benchmark_timeout = string2int(argv("benchmark_timeout", "-1"));

string expid             = getenv("EXPID");
string turbine_output    = getenv("TURBINE_OUTPUT");
string candle_model_type = getenv("CANDLE_MODEL_TYPE");

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

// compare(string exp_id, string run_id)
// {
//   python_persist("import compare",
//                  "compare.compare(\"%s\", \"%s\")") % (exp_id, run_id);
// }

compare(string model_name, string expid, string runid)
{
  printf("Calling compare with model_name: %s", model_name)=>
  python_persist("import compare", "compare.compare(\"%s\", \"%s\", \"%s\")" % (model_name, expid, runid) );
  // python_persist("import compare", "compare.compare()");
}

// Evaluate each parameter set
// foreach model, i in model_lines
// {
foreach gparam, j in gparams_lines
{
  // runid = i*1000000 + j;
  runid = j;

  printf("runid: %s", runid);
  // printf("model: %s", model);

  // printf("model: %s", model);
  // m = "\"model_name\": \"%s\"" % model;

  // gparams = replace(gparam, "MORE_PARAMS", m, 0);
  printf("gparams: %s", gparam);
  // printf("GPARAMS: %s", gparams);
  model_name = json_get(gparam, "model_name");
  candle_image = json_get(gparam, "candle_image");
  printf("MODEL: %s", model_name);
  // printf(gparams);
  // results[runid] = obj(gparam, expid, repr(runid) );
  model_script = "train.sh";
  results[runid] = obj_container(gparam, expid, repr(runid), model_name, candle_image, model_script) => compare(model_name, expid, repr(runid));
  // results[runid] = obj(gparam, expid, repr(runid));
  //  => compare(expid, repr(runid) );

  // assert(results[i] != "EXCEPTION", "exception in obj()!");
}
// }

// // Join all result values into one big semicolon-delimited string
// string result = join(run_ids, ";");
// // and print it
// printf("WORKFLOW RESULT: " + result);
