
/**
   OBJ PY SWIFT
*/

string code_template =
"""
import nt3_tc1_runner
import json, os

outdir = '%s'

if not os.path.exists(outdir):
    os.makedirs(outdir)

hyper_parameter_map = json.loads('%s')
hyper_parameter_map['framework'] = 'keras'
hyper_parameter_map['save'] = '{}/output'.format(outdir)
hyper_parameter_map['instance_directory'] = outdir
hyper_parameter_map['model_name'] = '%s'
hyper_parameter_map['experiment_id'] = '%s'
hyper_parameter_map['run_id'] = '%s'
hyper_parameter_map['timeout'] = %d

validation_loss = nt3_tc1_runner.run(hyper_parameter_map)
""";

(string obj_result) obj(string params, string iter_indiv_id) {
  string outdir = "%s/run_%s" % (turbine_output, iter_indiv_id);
  string code = code_template % (outdir, params, model_name, exp_id, iter_indiv_id, benchmark_timeout);
  obj_result = python_persist(code, "str(validation_loss)");
  printf(obj_result);
}
