
/*
  RECUR 1 SWIFT

  Simply run with: 'swift-t recur-1.swift | nl'
  Or specify the N, S values:
  'swift-t recur-1.swift -N=6 -S=6 | nl'
  for 55,986 tasks.
*/

import io;
import sys;

app (void v) dummy(string parent, int stage, int id, void block)
{
  "echo" ("parent='%3s'"%parent) ("stage="+stage) ("id="+id) ;
}

// Data split factor with default
N = string2int(argv("N", "4"));
// Maximum stage number with default
// (tested up to S=7, 21,844 dummy tasks)
S = string2int(argv("S", "3"));

(void v) runstage(int N, int S, string parent, int stage, int id, void block)
{
  this = parent+int2string(id);
  v = run_dummy(parent, stage, id, block);
  if (stage < S)
  {
    foreach id_child in [0:N-1]
    {
      runstage(N, S, this, stage+1, id_child, v);
    }
  }
}

(void v) run_dummy(string parent, int stage, int id, void block)
{
  if (stage == 0)
  {
    v = propagate();
  }
  else
  {
    v = dummy(parent, stage, id, block);
  }
}

stage = 0;
id = 0;
runstage(N, S, "", stage, id, propagate());
