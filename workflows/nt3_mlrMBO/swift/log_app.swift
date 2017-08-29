
// LOG APP

app (file out, file err) run_log_start(file shfile, string ps, string sys_env, string algorithm, string site)
{
    "bash" shfile "start" emews_root propose_points max_iterations ps algorithm exp_id sys_env site @stdout=out @stderr=err;
}

app (file out, file err) run_log_end(file shfile, string site)
{
    "bash" shfile "end" emews_root exp_id site @stdout=out @stderr=err;
}
