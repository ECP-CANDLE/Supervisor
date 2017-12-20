
/**
   OBJ PY SWIFT
   Swift EMEWS Objective Function - Python Implementation
*/

string code_template =
"""
import p3b1_runner
import json, os

outdir = '%s'

if not os.path.exists(outdir):
    os.makedirs(outdir)

hyper_parameter_map = json.loads('%s')
hyper_parameter_map['framework'] = 'keras'
hyper_parameter_map['save'] = '{}/output'.format(outdir)
hyper_parameter_map['instance_directory'] = outdir
hyper_parameter_map['experiment_id'] = '%s'
hyper_parameter_map['run_id'] = '%s'
hyper_parameter_map['timeout'] = %d

validation_loss = p3b1_runner.run(hyper_parameter_map)
""";

string code_log_start =
"""
import exp_logger

parameter_map = {}
parameter_map['pp'] = '%d'
parameter_map['iterations'] = '%d'
parameter_map['params'] = \"\"\"%s\"\"\"
parameter_map['algorithm'] = '%s'
parameter_map['experiment_id'] = '%s'
sys_env = \"\"\"%s\"\"\"

exp_logger.start(parameter_map, sys_env)
""";

string code_log_end =
"""
import exp_logger

exp_logger.end('%s')
""";

// algorithm params format is a string representation
// of a python dictionary. eqpy_hyperopt evals this
// string to create the dictionary. This, unfortunately,
string algo_params_template =
"""
max.budget = %d, max.iterations = %d, design.size=%d, propose.points=%d, param.set.file='%s'
""";

(string obj_result) obj(string params, string iter_indiv_id) {
  string outdir = "%s/run_%s" % (turbine_output, iter_indiv_id);
  string code = code_template % (outdir, params, exp_id, iter_indiv_id, benchmark_timeout);
  //make_dir(outdir) =>
  obj_result = python_persist(code, "str(validation_loss)");
  printf(obj_result);
}
