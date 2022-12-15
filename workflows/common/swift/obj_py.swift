
/**
   OBJ PY SWIFT
*/

string code_template =
----
try:
  import json
  import os
  import sys
  import traceback
  import model_runner

  sys.argv = [ 'python' ]
  import tensorflow
  from tensorflow import keras

  obj_result = '-100'
  outdir = '%s'

  if not os.path.exists(outdir):
      os.makedirs(outdir)

  J = """%s"""
  hyper_parameter_map = json.loads(J)
  hyper_parameter_map['framework'] = 'keras'
  hyper_parameter_map['save'] = '{}/output'.format(outdir)
  hyper_parameter_map['instance_directory'] = outdir
  hyper_parameter_map['model_name'] = '%s'
  hyper_parameter_map['experiment_id'] = '%s'
  hyper_parameter_map['run_id'] = '%s'
  hyper_parameter_map['timeout'] = %d

  obj_result, history = model_runner.run_model(hyper_parameter_map)

except Exception as e:
  info = sys.exc_info()
  s = traceback.format_tb(info[2])
  sys.stdout.write('\\n\\nEXCEPTION in obj() code: \\n' +
                   repr(e) + ' ... \\n' + ''.join(s))
  sys.stdout.write('\\n')
  sys.stdout.flush()
  obj_result = 'EXCEPTION'
----;

(string obj_result) obj(string params, string iter_indiv_id) {
  string outdir = "%s/run/%s" % (turbine_output, iter_indiv_id);
  string code = code_template % (outdir, params, model_name,
                                 exp_id, iter_indiv_id, benchmark_timeout);
  obj_result = python_persist(code, "str(obj_result)");
  printf("obj_py:obj(): obj_result: '%s'", obj_result);
}
