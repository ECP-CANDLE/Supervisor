import io;
import sys;
import files;
import location;
import string;
import EQR;
import R;
import assert;

string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");
string resident_work_ranks = getenv("RESIDENT_WORK_RANKS");
string r_ranks[] = split(resident_work_ranks,",");

string obj_fun_template = ----
  res <- sum(c(%s)^2)
----;


(string result) obj(string params) {
    string r_code = obj_fun_template % params;
    result = R(r_code, "toString(res)");
}

(void v) loop(location ME, int ME_rank) {

    for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
  {
    string params =  EQR_get(ME);
    boolean c;

    // TODO
    // Edit the finished flag, if necessary.
    // when the python algorithm is finished it should
    // pass "DONE" into the queue, and then the
    // final set of parameters. If your python algorithm
    // passes something else then change "DONE" to that
    if (params == "DONE")
    {
      string finals =  EQR_get(ME);
      string fname = "%s/final_result_%i" % (turbine_output, ME_rank);
      file results_file <fname> = write(finals) =>
      printf("Writing final result to %s", fname) =>
      // printf("Results: %s", finals) =>
      v = make_void() =>
      c = false;
    }
    else if (params == "EQR_ABORT")
    {
      printf("EQR aborted: see output for R error") =>
      string why = EQR_get(ME);
      printf("%s", why) =>
      v = propagate() =>
      c = false;
    }
    else
    {

        string param_array[] = split(params, ";");
        string results[];
        foreach p, j in param_array
        {
            results[j] = obj(p);
        }
        string res = join(results, ";");
        EQR_put(ME, res) => c = true;

    }
  }
}

(void o) start(int ME_rank, int propose_points, int max_iterations) {
    location ME = locationFromRank(ME_rank);
    // TODO: Edit algo_params to include those required by the R
    // algorithm.
    // algo_params are the parameters used to initialize the
    // R algorithm. We pass these as a comma separated string.
    // By default we are passing a random seed. String parameters
    // should be passed with a \"%s\" format string.
    // e.g. algo_params = "%d,%\"%s\"" % (random_seed, "ABC");
    string algo_params = "pp = %d, it = %d" % (propose_points, max_iterations);
    string algorithm = strcat(emews_root,"/R/simple_mlrMBO.R");
    EQR_init_script(ME, algorithm) =>
    EQR_get(ME) =>
    EQR_put(ME, algo_params) =>
    loop(ME, ME_rank) => {
        EQR_stop(ME) =>
        EQR_delete_R(ME);
        o = propagate();
    }
}

main() {

  // Retrieve arguments to this script here
  int propose_points = toint(argv("pp", "3"));
  int max_iterations = toint(argv("it", "5"));

  assert(strlen(emews_root) > 0, "Set EMEWS_PROJECT_ROOT!");

  int ME_ranks[];
  foreach r_rank, i in r_ranks{
    ME_ranks[i] = toint(r_rank);
  }

  //run_prerequisites() => {
    foreach ME_rank, i in ME_ranks {
      start(ME_rank, propose_points, max_iterations) =>
      printf("End rank: %d", ME_rank);
    }
//}
}
