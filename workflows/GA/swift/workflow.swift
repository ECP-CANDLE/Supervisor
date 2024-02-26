
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

string strategy = argv("strategy", "mu_plus_lambda");
string ga_params_file = argv("ga_params");
// string init_params_file = argv("init_params", "");
float off_prop = string2float(argv("off_prop", "0.5"));
float mut_prob = string2float(argv("mut_prob", "0.8"));
float cx_prob = string2float(argv("cx_prob", "0.2"));
float mut_indpb = string2float(argv("mut_indpb", "0.5"));
float cx_indpb = string2float(argv("cx_indpb", "0.5"));
int tournsize = string2int(argv("tournsize", "4"));

string exp_id = argv("exp_id");
int benchmark_timeout = string2int(argv("benchmark_timeout", "-1"));

printf("TURBINE_OUTPUT: " + turbine_output);

string restart_number = argv("restart_number", "1");

string FRAMEWORK = getenv("FRAMEWORK");
assert(FRAMEWORK != "", "workflow.swift: Set FRAMEWORK!");

// Entry point:
main {

  int random_seed = string2int(argv("seed", "0"));
  int num_iter = string2int(argv("ni","5"));
  int num_pop = string2int(argv("np","8"));
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

  algo_params = "%d,%d,%d,'%s',%f,%f,%f,%f,%f,%d,'%s','%s'" %
    (iters, pop, seed, strategy, off_prop, mut_prob, cx_prob, mut_indpb, cx_indpb, tournsize, ga_params_file, init_params_file);

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
      // Algorithm has terminated with final results.
      v = get_results(ME, ME_rank) =>
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

(void v)
get_results(location ME, int ME_rank)
{
  printf("Writing final results to %s", turbine_output);

  // Retrieve results from algorithm:
  string best, fitness, population, fitnesses, deap_log;
  best         = EQPy_get(ME) =>
    fitness    = EQPy_get(ME) =>
    population = EQPy_get(ME) =>
    fitnesses  = EQPy_get(ME) =>
    deap_log   = EQPy_get(ME);

  // Construct filenames
  string filename_best =
    "%s/best-%i.json" % (turbine_output, ME_rank);
  string filename_fitness =
    "%s/fitness-%i.txt" % (turbine_output, ME_rank);
  string filename_population =
    "%s/population-%i.txt" % (turbine_output, ME_rank);
  string filename_fitnesses =
    "%s/fitnesses-%i.txt" % (turbine_output, ME_rank);
  string filename_deap_log =
    "%s/deap-%i.log" % (turbine_output, ME_rank);

  // Write the files (in parallel).
  // We append newlines to simple Python strings so files look normal.
  file file_best       <filename_best>        = write(best       + "\n");
  file file_fitness    <filename_fitness>     = write(fitness    + "\n");
  file file_population <filename_population>  = write(population + "\n");
  file file_fitnesses  <filename_fitnesses>   = write(fitnesses  + "\n");
  file file_deap_log   <filename_deap_log>    = write(deap_log   + "\n");

  // Wait for all files to be written:
  v = propagate(file_best, file_fitness, file_population,
                file_fitnesses, file_deap_log);
}

// Local Variables:
// c-basic-offset: 2
// End:
