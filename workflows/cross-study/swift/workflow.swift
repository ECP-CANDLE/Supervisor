
/**
   CROSS-STUDY WORKFLOW.SWIFT
*/

import assert;
import io;
import json;
import files;
import string;
import sys;

import candle_utils;
report_env();

string FRAMEWORK = "keras";

// Scan command line
file cs = input(argv("f"));
int  benchmark_timeout = string2int(argv("benchmark_timeout", "-1"));

string model_name     = getenv("MODEL_NAME");
string expid          = getenv("EXPID");
string turbine_output = getenv("TURBINE_OUTPUT");

// Report some key facts:
system1("date \"+%Y-%m-%d %H:%M\"");

string source_datasets[] = ["CCLE"];
string target_datasets[] = ["GDSC", "CTRP", "NCI60", "gCSI"];
int split_nums[] = [4, 7];
int epochs = 1;

// string source_datasets[];
// string target_datasets[];
// int split_nums[];
// int epochs;

printf("CS: %s", filename(cs));
string cs_lines[] = file_lines(cs);

// foreach params,i in cs_lines
// {
//   source_datasets = json_get(params, "source_datasets");
//   target_datasets = json_get(params, "target_datasets");
//   split_nums = json_get(params, "split_nums");
//   epochs = json_get(params, "epochs");
// }



json_template = """
{
  "epochs"     : %2i,
  "source_dataset" : "%s",
  "target_dataset" : "%s",
  "split"      : %2i
}
""";


foreach source_dataset in source_datasets
{
  foreach split in split_nums
  {
      // test sources for the trained model
      foreach target_dataset in target_datasets
      {
        if (target_dataset != source_dataset)
        {
          runid = source_dataset+"_"+split+"_"+target_dataset;
          // make params to pass info about train_dataset, split, target_dataset
          params = json_template %
            (epochs, source_dataset, target_dataset, split);
          printf("Running with:- train_source, target_dataset, split: %s, %s,%s, %i", runid, source_dataset, target_dataset, split);
          results = candle_model_train(params, expid, runid, model_name);
          // assert(results != "EXCEPTION", "exception in candle_model_train()!");
        }
      }
  }
}