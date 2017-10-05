
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
