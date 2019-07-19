app (void v) dummy(string parent, int stage, int id, void block)
{
  "echo" ("parent='%3s'"%parent) ("stage="+stage) ("id="+id) ;
}

(void v) db_setup()
{
  python_persist(----
import db_cplo_init
global db_file
db_file = 'cplo.db'
db_cplo_init.main(db_file)
----,
----
'OK'
----) =>
    v = propagate();
}
