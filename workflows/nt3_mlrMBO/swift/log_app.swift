
// LOG APP

app (file out, file err) run_log_start(file shfile, string ps, string sys_env, string algorithm)
{
    "bash" shfile "start" emews_root propose_points max_iterations ps algorithm exp_id sys_env @stdout=out @stderr=err;
}

app (file out, file err) run_log_end(file shfile)
{
    "bash" shfile "end" emews_root exp_id @stdout=out @stderr=err;
}
