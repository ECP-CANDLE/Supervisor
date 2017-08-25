
// LOG APP

app (file out, file err) run_log_start(file shfile, string ps, string sys_env, string algorithm)
{
    "bash" shfile "start" emews_root propose_points max_iterations ps algorithm exp_id sys_env @stdout=out @stderr=err;
}

app (file out, file err) run_log_end(file shfile)
{
    "bash" shfile "end" emews_root exp_id @stdout=out @stderr=err;
}

(void o) log_start(string algorithm) {
    file out <"%s/log_start_out.txt" % turbine_output>;
    file err <"%s/log_start_err.txt" % turbine_output>;

    string ps = join(file_lines(input(param_set)), " ");
    string t_log = "%s/turbine.log" % turbine_output;
    if (file_exists(t_log)) {
      string sys_env = join(file_lines(input(t_log)), ", ");
      (out, err) = run_log_start(log_script, ps, sys_env, algorithm) =>
      o = propagate();
    } else {
      (out, err) = run_log_start(log_script, ps, "", algorithm) =>
      o = propagate();
    }
}

(void o) log_end() {
  file out <"%s/log_end_out.txt" % turbine_output>;
  file err <"%s/log_end_err.txt" % turbine_output>;
  (out, err) = run_log_end(log_script) =>
  o = propagate();
}
