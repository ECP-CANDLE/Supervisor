
/*
  WORKFLOW SWIFT

  Simply run with: 'swift-t workflow.swift'
  Or specify the N, S values:
  'swift-t workflow.swift -N=6 -S=6'
  for 55,986 tasks.
  N: Number of nodes per stage
  S: Number of stages
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

(void v)
run_stage(int N, int S, string this, int stage, void block)
{
  printf("stage: %i this: %s", stage, this);
  void parent = run_single(this, stage, block);
  if (stage < S)
  {
    foreach id_child in [1:N]
    {
      run_stage(N, S, this+"."+id_child, stage+1, parent);
    }
  }
  v = propagate();
}

(void v) run_single(string this, int stage, void block)
{
// "pre_module":  "data_setup",
// "post_module": "data_setup",

  json_fragment = make_json_fragment(this, stage);
  if (stage == 0)
  {
    // db_setup() => // cf. junk.swift
      v = propagate();
  }
  else
  {
    node = this;
    json = "{\"node\": \"%s\", %s}" % (node, json_fragment);
    block =>
      printf("running obj(%s)", node) =>
      s = obj(json, node);
    v = propagate(s);
    // v = dummy(parent, stage, id, block); // cf. junk.swift
  }
}

(string result) make_json_fragment(string this, int stage)
{
    json_fragment = ----
"plan":        "/home/wozniak/plan.json",
"config_file":        "uno_auc_model.txt",
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

stage = 0;
run_stage(N, S, "1", stage, propagate()) =>
  printf("RESULTS: COMPLETE");
