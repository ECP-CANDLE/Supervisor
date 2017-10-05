
// LOG APP

(void o) log_start(string algorithm) {
    file out<turbine_output/"log_start_out.txt">;
    file err<turbine_output/"log_start_err.txt">;

    string ps = join(file_lines(input(param_set)), " ");
    string t_log = turbine_output/"turbine.log";
    if (file_exists(t_log)) {
      string sys_env = join(file_lines(input(t_log)), ", ");
      (out, err) = run_log_start(log_runner, ps, sys_env, algorithm, site) =>
      o = propagate();
    } else {
      (out, err) = run_log_start(log_runner, ps, "", algorithm, site) =>
      o = propagate();
    }
}

(void o) log_end() {
  file out <"%s/log_end_out.txt" % turbine_output>;
  file err <"%s/log_end_err.txt" % turbine_output>;
  (out, err) = run_log_end(log_runner, site) =>
  o = propagate();
}

app (file out, file err) run_log_start(file shfile, string ps, string sys_env, string algorithm, string site)
{
    "bash" shfile "start" emews_root propose_points max_iterations ps algorithm exp_id sys_env site @stdout=out @stderr=err;
}

app (file out, file err) run_log_end(file shfile, string site)
{
    "bash" shfile "end" emews_root exp_id site @stdout=out @stderr=err;
}
