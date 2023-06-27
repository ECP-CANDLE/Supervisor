
/*
 * WORKFLOW.SWIFT
 */

// Standard Swift/T features:
import assert;
import io;
import sys;
import files;
import location;
import string;
import unix;
import assert;
import python;

// The EMEWS Python module:
import EQPy;

// Report the environment for debugging:
import candle_utils;
report_env();

// Settings from environment
string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");
string resident_work_ranks = getenv("RESIDENT_WORK_RANKS");
string r_ranks[] = split(resident_work_ranks,",");
string model_name        = getenv("MODEL_NAME");
string init_params_file  = getenv("INIT_PARAMS_FILE");

// Command line arguments:
string site = argv("site");
string strategy = argv("strategy");
string ga_params_file = argv("ga_params");
// string init_params_file = argv("init_params", "");
float mut_prob  = string2float(argv("mutation_prob", "0.2"));
int random_seed = string2int(argv("seed", "0"));
int num_iter    = string2int(argv("ni","100"));
int num_pop     = string2int(argv("np","100"));

string exp_id = argv("exp_id");
int benchmark_timeout = string2int(argv("benchmark_timeout", "-1"));

printf("TURBINE_OUTPUT: " + turbine_output);

string restart_number = argv("restart_number", "1");

string FRAMEWORK = "keras";

// Entry point:
main {

  assert(strlen(emews_root) > 0, "Set EMEWS_PROJECT_ROOT!");

  // Ranks for the DEAP algorithm.
  // Normally just a single rank, running on the 2nd highest rank
  // in COMM WORLD
  int ME_ranks[];
  foreach r_rank, i in r_ranks {
    ME_ranks[i] = string2int(r_rank);
  }

  // Start the algorithm:
  foreach ME_rank, i in ME_ranks {
    start(ME_rank, num_iter, num_pop, random_seed) =>
      printf("End rank: %d", ME_rank);
  }
}

// Initialize the algorithm and start the iteration loop:
(void o) start (int ME_rank, int iters, int pop, int seed) {
  location ME = locationFromRank(ME_rank);
  // (num_iter, num_pop, seed, strategy, mut_prob, ga_params_file)
  algo_params = "%d,%d,%d,'%s',%f, '%s', '%s'" %
    (iters, pop, seed, strategy, mut_prob, ga_params_file, init_params_file);
  EQPy_init_package(ME, "deap_ga") =>
    EQPy_get(ME) =>
    EQPy_put(ME, algo_params) =>
    loop(ME, ME_rank) => {
    EQPy_stop(ME);
    o = propagate();
  }
}

// Loop over parameters from algorithm:
(void v) loop(location ME, int ME_rank) {
  for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
  {
    // Get parameters from algorithm:
    string params =  EQPy_get(ME);
    boolean c;

    if (params == "DONE")
    {
      // Algorithm has terminated with a final result.
      string finals =  EQPy_get(ME);
      string fname = "%s/final_result_%i" % (turbine_output, ME_rank);
      file results_file <fname> = write(finals) =>
        printf("Writing final result to %s", fname) =>
        // printf("Results: %s", finals) =>
        v = make_void() =>
        c = false;
    }
    else if (params == "EQPY_ABORT")
    {
      // Algorithm encountered an error.
      printf("EQPy aborted...");
      // Get and print the exception text:
      string why = EQPy_get(ME);
      printf("%s", why) =>
        v = propagate() =>
        c = false =>
        assert(false, "EQPY aborted!");
    }
    else
    {
      // Got good parameters.
      // Split, distribute, and train in parallel:
      string param_array[] = split(params, ";");
      string results[];
      foreach param, j in param_array
      {
        run_id = "run_%02i_%03i_%04i" % (restart_number, i, j);
        results[j] =
          candle_model_train(param, exp_id, run_id, model_name);
      }
      string result = join(results, ";");
      EQPy_put(ME, result) => c = true;
    }
  }
}


// Local Variables:
// c-basic-offset: 2
// End:
