
/**
   CANDLE MODEL: PY
   Runs CANDLE models as Swift/T python() functions
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

  model_result = '-100'
  outdir = '%s'

  if not os.path.exists(outdir):
      os.makedirs(outdir)

  J = """%s"""
  hyper_parameter_map = json.loads(J)
  hyper_parameter_map['framework'] = 'keras'
  hyper_parameter_map['framework'] = 'keras'
  hyper_parameter_map['save'] = '{}/output'.format(outdir)
  hyper_parameter_map['instance_directory'] = outdir
  hyper_parameter_map['model_name'] = '%s'
  hyper_parameter_map['experiment_id'] = '%s'
  hyper_parameter_map['run_id'] = '%s'
  hyper_parameter_map['timeout'] = %d

  model_result, history = model_runner.run_model(hyper_parameter_map)

except Exception as e:
  info = sys.exc_info()
  s = traceback.format_tb(info[2])
  sys.stdout.write('\\n\\nEXCEPTION in candle_model_train(): \\n' +
                   repr(e) + ' ... \\n' + ''.join(s))
  sys.stdout.write('\\n')
  sys.stdout.flush()
  model_result = 'EXCEPTION'
----;

(string model_result) candle_model_train(string params,
                                         string expid,
                                         string runid,
                                         string model_name)
{
  string outdir = "%s/run/%s" % (turbine_output, runid);
  string code = code_template % (outdir, params, model_name,
                                 expid, runid, benchmark_timeout);
  model_result = python_persist(code, "str(model_result)");
  printf("model_py:candle_model_train(): model_result: '%s'", model_result);
}
