
/*
  RECUR 1 SWIFT

  Simply run with: 'swift-t recur-1.swift | nl'
*/

app (void v) dummy(string parent, int stage, int id, void block)
{
  "echo" ("parent='%3s'"%parent) ("stage="+stage) ("id="+id) ;
}

N = 4;

void A[string];

(void v) runstage(int N, string parent, int stage, int id, void block)
{
  string this = parent+int2string(id);
  v = dummy(parent, stage, id, block);
  if (stage < 3)
  {
    foreach id_child in [0:N-1]
    {
      runstage(N, this, stage+1, id_child, v);
    }
  }
}

int stage = 1;
foreach id in [0:N-1]
{
  runstage(N, "", stage, id, propagate());
}
