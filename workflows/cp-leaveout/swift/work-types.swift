
pragma worktypedef DB;

@dispatch=DB
(string output) pydb(string code, string expr)
"turbine" "0.1.0"
 [ "set <<output>> [ turbine::python 1 1 <<code>> <<expr>> ]" ];

app rank()
{
  "./rank.sh" ;
}

foreach i in [0:3]
{
  pid = pydb("import os", "repr(os.getenv(\"PMI_RANK\"))");
  trace("pid", pid);
  rank();
}
