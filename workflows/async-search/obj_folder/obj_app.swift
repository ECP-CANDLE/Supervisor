
// OBJ APP


() obj(string params, string run_id, int dest) {
  string template = """
from __future__ import print_function
# template args
params = '''%s'''
runid = "%s"
destination = %i
model_sh = "%s"
outdir = "%s"
num_turbine_workers = %i

import json
from mpi4py import MPI
import subprocess, sys
import os

# Init
try:
  newgroup
except NameError:
  comm = MPI.COMM_WORLD
  rank = comm.Get_rank()
  #print("orig rank: " + str(rank))
  group = comm.Get_group()
  # Assumes only one adlb_server
  newgroup = group.Excl([num_turbine_workers])
  newcomm = comm.Create_group(newgroup,1)

rank = newcomm.Get_rank()
#print("new rank: " + str(rank))

# Call

bash = '/bin/bash'
cmd = [bash,model_sh,"keras","{}".format(params), runid]
p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
#print("just launched cmd: " + ":".join(cmd))
out,err = p.communicate()
#print("out: ", out)
#print("err: ", err)
#rc = p.returncode
#print("rc: ", rc)


# Collect
result_file = outdir + "/result.txt"

if os.path.exists(result_file):
    with open(result_file) as f:
        pvalstring =  f.read().strip()
else:
    pvalstring = "NaN"

pval = float(pvalstring)


# Send

resDict = {}
resDict['cost'] = pval
resDict['x'] = params.strip()
newcomm.send(resDict, dest=destination)
result = str(pval)
""";
  printf("params variable is: " + params);
  string model_sh       = getenv("MODEL_SH");
  string turbine_output = getenv("TURBINE_OUTPUT");
  string outdir = "%s/run/%s" % (turbine_output, run_id);
  # Note: currently framework is hardcoded to "keras"
  int num_turbine_workers = turbine_workers();
  string code = template % (params, run_id, dest, model_sh, outdir, num_turbine_workers);
  string res = python_persist(code, "result");
  printf("obj() result: " + res + " (for params: " + params +")");
}
