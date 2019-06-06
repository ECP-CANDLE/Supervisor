
/*
  RECUR 1 SWIFT

  Simply run with: 'swift-t recur-1.swift | nl'
  Or specify the N, S values:
  'swift-t recur-1.swift -N=6 -S=6 | nl'
  for 55,986 tasks.
*/

/*
  CP LEAVEOUT SWIFT
  Main workflow
*/

import assert;
import files;
import io;
import python;
import unix;
import sys;
import string;
import location;
import math;

string FRAMEWORK = "keras";

string xcorr_root = getenv("XCORR_ROOT");
string preprocess_rnaseq = getenv("PREPROP_RNASEQ");
string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");

printf("TURBINE_OUTPUT: " + turbine_output);

string db_file = argv("db_file");
string cache_dir = argv("cache_dir");
// string xcorr_data_dir = argv("xcorr_data_dir");
string gpus = argv("gpus", "");

// string restart_number = argv("restart_number", "1");
string site = argv("site");

// dummy() is now unused- retaining for debugging/demos
// app (void v) dummy(string parent, int stage, int id, void block)
// {
//   "echo" ("parent='%3s'"%parent) ("stage="+stage) ("id="+id) ;
// }

// Data split factor with default
N = string2int(argv("N", "2"));
// Maximum stage number with default
// (tested up to S=7, 21,844 dummy tasks)
S = string2int(argv("S", "2"));

(void v) run_stage(int N, int S, string parent, int stage, int id, void block)
{
  string node;
  if (parent == "")
  {
    node = int2string(id);
  }
  else
  {
    node = parent+"."+int2string(id);
  }
  // node = parent+"."+int2string(id);
  v = run_node(parent, stage, id, block);
  if (stage < S)
  {
    foreach id_child in [0:N-1]
    {
      run_stage(N, S, node, stage+1, id_child, v);
    }
  }
}

(void v) run_node(string node, int stage, int id, void block)
{
  if (stage == 0)
  {
    v = propagate();
  }
  else
  {
    // dummy() is now unused- retaining for debugging/demos
    // v = dummy(parent, stage, id, block);

    json = "{\"node\": \"%s\"}"%node;
    s = obj(json, node);
    v = propagate(s);
  }
}

stage = 0;
id = 0;
run_stage(N, S, "", stage, id, propagate());
