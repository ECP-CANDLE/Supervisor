import io;
import sys;
import files;
import location;
import string;
import unix;
import assert;
import python;
// OBJ APP


(string result) obj(string params, string run_id, int dest) {
  string template = """
from __future__ import print_function
# template args
params = '''%s'''

print("params: " + params)
runid = "%s"
destination = %i
model_sh = "%s"
outdir = "%s"

import json
import subprocess, sys
import os

# Init

# Call
bash = '/bin/bash'
cmd = [bash,model_sh,"keras","{}".format(params), runid]
p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
#p = subprocess.Popen(["/bin/bash","/home/jozik/repos/Supervisor/workflows/asnyc-search/test/hello.sh"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
print("just launched cmd: " + ":".join(cmd))
out,err = p.communicate()
print("out: ", out)
print("err: ", err)
#for line in p.stdout:
#  print(line)
#p.wait()

#print("stdout: ", p.stdout)
#print("stderr: ", p.stderr)

rc = p.returncode

print("rc: ", rc)

# Collect
result_file = outdir + "/result.txt"

if os.path.exists(result_file):
    with open(result_file) as f:
        pvalstring =  f.read().strip()
else:
    pvalstring = "NaN"

pval = float(pvalstring)

# Send

result = str(pval)
""";
  printf("params variable is: " + params);
  string model_sh       = getenv("MODEL_SH");
  string turbine_output = getenv("TURBINE_OUTPUT");
  string outdir = "%s/run/%s" % (turbine_output, run_id);
  string code = template % (params, run_id, dest, model_sh, outdir);
  result = python_persist(code, "result");
  printf("obj() result: " + result);
}

int C[] = [4,5];



string results[];
foreach j, i in C {
  results[i] = obj("{\"epochs\":1, \"feature_subsample\": 100, \"conv\": [0, 0, 0]}","id%i" % j, 2);
}
string result = join(results, ";");
printf("result is: " + result);
