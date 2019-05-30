
/*
  RECUR 1 SWIFT

  Simply run with: 'swift-t recur-1.swift | nl'
*/

app (void v) dummy(string parent, int stage, int id, void block)
{
  "echo" ("parent='%3s'"%parent) ("stage="+stage) ("id="+id) ;
}

N = 4; // Data split factor
S = 3; // Maximum stage number (tested up to S=7, 21,844 dummy tasks)

(void v) runstage(int N, int S, string parent, int stage, int id, void block)
{
  string this = parent+int2string(id);
  v = dummy(parent, stage, id, block);
  if (stage < S)
  {
    foreach id_child in [0:N-1]
    {
      runstage(N, S, this, stage+1, id_child, v);
    }
  }
}

int stage = 1;
foreach id in [0:N-1]
{
  runstage(N, S, "", stage, id, propagate());
}
