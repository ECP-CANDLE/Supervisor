
/**
   LOG PY SWIFT
*/

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

(void o) log_start(string algorithm) {
    string ps = join(file_lines(input(param_set)), " ");
    string sys_env = join(file_lines(input("%s/turbine.log" % turbine_output)), ", ");
    string code = code_log_start % (propose_points, max_iterations, ps, algorithm, exp_id, sys_env);
    python_persist(code);
    o = propagate();
}

(void o) log_end(){
    string code = code_log_end % (exp_id);
    python_persist(code);
    o = propagate();
}
