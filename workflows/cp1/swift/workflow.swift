
/*
  XCORR SWIFT
  Main cross-correlation workflow
*/

import files;
import io;
import python;
import unix;
import sys;
import string;
import EQR;
import location;
import math;

string FRAMEWORK = "keras";

string xcorr_root = getenv("XCORR_ROOT");
string preprocess_rnaseq = getenv("PREPROP_RNASEQ");
string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");

printf("TURBINE_OUTPUT: " + turbine_output);

string db_file = argv("db_file");
string cache_dir = argv("cache_dir");
string xcorr_data_dir = argv("xcorr_data_dir");
string gpus = argv("gpus", "");

string resident_work_ranks = getenv("RESIDENT_WORK_RANKS");
string r_ranks[] = split(resident_work_ranks,",");
int propose_points = toint(argv("pp", "3"));
int max_budget = toint(argv("mb", "110"));
int max_iterations = toint(argv("it", "5"));
int design_size = toint(argv("ds", "10"));
string param_set = argv("param_set_file");
string exp_id = argv("exp_id");
int benchmark_timeout = toint(argv("benchmark_timeout", "-1"));
string restart_file = argv("restart_file", "DISABLED");
string r_file = argv("r_file", "mlrMBO1.R");

string restart_number = argv("restart_number", "1");
string site = argv("site");

if (restart_file != "DISABLED") {
  assert(restart_number != "1",
         "If you are restarting, you must increment restart_number!");
}


// for subset of studies, comment '#' out study name in studiesN.txt
string studies1[] = file_lines(input(emews_root + "/data/studies1.txt"));
string studies2[] = file_lines(input(emews_root + "/data/studies2.txt"));
string rna_seq_data = argv("rna_seq_data"); //"%s/test_data/combined_rnaseq_data_lincs1000_%s.bz2" % (xcorr_root, preprocess_rnaseq);
string drug_response_data = argv("drug_response_data"); //xcorr_root + "/test_data/rescaled_combined_single_drug_growth_100K";
int cutoffs[][] = [[200, 100]]; //,
                 //  [100, 50],
                 //  [400, 200],
                  //  [200, 50],
                  //  [400, 50],
                  //  [400, 100]];

string update_param_template =
"""
import json

params = json.loads('%s')
# --cell_feature_subset_path $FEATURES --train_sources $STUDY1 --preprocess_rnaseq $PREPROP_RNASEQ
params['train_sources'] = '%s'
params['preprocess_rnaseq'] = '%s'
gpus = '%s'
if len(gpus) > 0:
  params['gpus'] = gpus.replace(',', ' ')


cell_feature_subset_path = '%s'
if len(cell_feature_subset_path) > 0:
  params['cell_feature_subset_path'] = cell_feature_subset_path
  import os
  cf = os.path.basename(params['cell_feature_subset_path'])
  idx = cf.rfind('.')
  if idx != -1:
    cf = cf[:idx]
else:
  cf = "all_features"
  params['use_landmark_genes'] = True

params['cache'] = '%s/{}_cache'.format(cf)
params_json = json.dumps(params)
""";

string log_corr_template =
"""
from xcorr_db import xcorr_db, setup_db

global DB
DB = setup_db('%s')

feature_file = '%s'
if len(feature_file) > 0:
  features = DB.scan_features_file(feature_file)
else:
  # if no feature file, then use all the features
  id_to_names, _ = DB.read_feature_names()
  features = id_to_names.values()

study1 = '%s'
study2 = '%s'
if len(study2) == 0:
  studies = [study1]
else:
  studies = [study1, study2]

record_id = DB.insert_xcorr_record(studies=studies,
                       features=features,
                       cutoff_corr=%d, cutoff_xcorr=%d)
""";


(string hpo_id) insert_hpo(string xcorr_record_id) 
{
  hpo_template =
"""
from xcorr_db import xcorr_db, setup_db

global DB
DB = setup_db('%s')
hpo_id = DB.insert_hpo_record(%s)
""";

  code = hpo_template % (db_file, xcorr_record_id);
  hpo_id = python_persist(code, "str(hpo_id)");
}

(string run_id) insert_hpo_run(string hpo_id, string param_string, string run_directory) 
{
  run_template =
"""
from xcorr_db import xcorr_db, setup_db

global DB
DB = setup_db('%s')
run_id = DB.insert_hpo_run(%s, '%s', '%s')
""";

  code = run_template % (db_file, hpo_id, param_string, run_directory);
  run_id = python_persist(code, "str(run_id)");
}

(void o) update_hpo_run(string run_id, string result) 
{
  update_template =
"""
from xcorr_db import xcorr_db, setup_db

global DB
DB = setup_db('%s')
hpo_id = DB.update_hpo_run(%s, %s)
""";

  code = update_template % (db_file, run_id, result);
  python_persist(code, "'ignore'") =>
  o = propagate();
}

(string record_id)
compute_feature_correlation(string study1, string study2,
                            int corr_cutoff, int xcorr_cutoff,
                            string features_file)
{
  xcorr_template =
"""
rna_seq_data = '%s'
drug_response_data = '%s'
study1 = '%s'
study2 = '%s'
correlation_cutoff = %d
cross_correlation_cutoff = %d
features_file = '%s'

import uno_xcorr

if uno_xcorr.gene_df is None:
    uno_xcorr.init_uno_xcorr(rna_seq_data, drug_response_data)

uno_xcorr.coxen_feature_selection(study1, study2,
                                  correlation_cutoff,
                                  cross_correlation_cutoff,
                                  output_file=features_file)
""";

  log_code = log_corr_template % (db_file, features_file, study1, study2,
                                  corr_cutoff, xcorr_cutoff);
  // xcorr_code = xcorr_template % (rna_seq_data, drug_response_data,
  //                                study1, study2,
  //                                corr_cutoff, xcorr_cutoff,
  //                                features_file);
  // python_persist(xcorr_code) =>
  record_id = python_persist(log_code, "str(record_id)");
}

(void v) loop(string hpo_db_id, int init_prio, int modulo_prio, int mlr_instance_id, location ME, string feature_file,
    string train_source)
{
  for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
  {
    string params =  EQR_get(ME);
    boolean c;

    if (params == "DONE")
    {
      string finals =  EQR_get(ME);
      string fname = "%s/%i_final_res.Rds" % (turbine_output, mlr_instance_id);
      printf("See results in %s", fname) =>
      // printf("Results: %s", finals) =>
      v = propagate(finals) =>
      c = false;
    }
    else if (params == "EQR_ABORT")
    {
      printf("EQR aborted: see output for R error") =>
      string why = EQR_get(ME);
      printf("%s", why) =>
          // v = propagate(why) =>
      c = false;
    }
    else
    {
        int prio = init_prio - i * modulo_prio;
        string param_array[] = split(params, ";");
        string results[];
        foreach param, j in param_array
        {
            param_code = update_param_template % (param, train_source, preprocess_rnaseq,
                gpus, feature_file, cache_dir);
            string updated_param = python_persist(param_code, "params_json");
            // TODO DB: insert updated_param with mlr_instance_id and record
            //printf("Updated Params: %s", updated_param);
            //printf("XXX %s: %i", feature_file, prio);
            string run_id = "%00i_%00i_%000i_%0000i" % (mlr_instance_id, restart_number,i,j);
            string run_dir = "%s/run/%s" % (turbine_output, run_id);
            string run_db_id = insert_hpo_run(hpo_db_id, updated_param, run_dir) =>
            results[j] = obj_prio(updated_param, run_id, prio);
            //results[j] = "0.234234";
            update_hpo_run(run_db_id, results[j]);
            // TODO DB: insert result with record_id
        }
        string result = join(results, ";");
        // printf(result);
        EQR_put(ME, result) => c = true;
    }
  }
}


// These must agree with the arguments to the objective function in mlrMBO.R,
// except param.set.file is removed and processed by the mlrMBO.R algorithm wrapper.
string algo_params_template =
"""
param.set.file='%s',
max.budget = %d,
max.iterations = %d,
design.size=%d,
propose.points=%d,
restart.file = '%s'
""";

// (void o) start(int ME_rank, string record_id, string feature_file, string study1) {
//   printf("starting %s, %s, %s on %i", record_id, feature_file, study1, ME_rank) =>
//   o = propagate();
// }

(void o) start(int init_prio, int modulo_prio, int ME_rank, string record_id, string feature_file, string study1) {
    location ME = locationFromRank(ME_rank);
    int mlr_instance_id = abs_integer(init_prio);
    // algo_params is the string of parameters used to initialize the
    // R algorithm. We pass these as R code: a comma separated string
    // of variable=value assignments.
    string algo_params = algo_params_template %
        (param_set, max_budget, max_iterations, design_size,
         propose_points, restart_file);
    // DB: insert algo params with mlr_instance_id
    string algorithm = emews_root+"/../common/R/"+r_file;
    string hpo_db_id = insert_hpo(record_id) =>
    EQR_init_script(ME, algorithm) =>
    EQR_get(ME) =>
    EQR_put(ME, algo_params) =>
    loop(hpo_db_id, init_prio, modulo_prio, mlr_instance_id, ME, feature_file, study1) => {
        EQR_stop(ME) =>
        EQR_delete_R(ME);
        o = propagate();
    }
}

(int keys[]) sort_keys(string params[][]) {
  sort_code =
"""
key_string = '%s'
keys = [int(x) for x in key_string.split(',')]
keys.sort()
result = ",".join([str(x) for x in keys])
""";

  string k[] = keys_string(params);
  string code = sort_code % (join(k, ","));
  result = python_persist(code, "result");
  foreach val, i in split(result, ",")
  {
    keys[i] = string2int(val);
  }
}

main() {
  string params[][];

  foreach study1, i in studies1
  {
    foreach study2 in studies2
    {
      if (study1 != study2)
      {
        foreach cutoff in cutoffs
        {
          printf("Study1: %s, Study2: %s, cc: %d, ccc: %d",
                study1, study2, cutoff[0], cutoff[1]);
          fname = "%s/%s_%s_%d_%d_features.txt" %
            (xcorr_data_dir, study1, study2, cutoff[0], cutoff[1]);
          printf(fname);

          string record_id = compute_feature_correlation(study1, study2, cutoff[0], cutoff[1], fname);
          int h = string2int(record_id);
          params[h] = [record_id, fname, study1];
        }
      }
    }

     // for each of the studies, run against full features, no xcorr
    string log_code = log_corr_template % (db_file, "", study1, "", -1, -1);
    string record_id = python_persist(log_code, "str(record_id)");
    // give full features key value guaranteed to be lower than the record_ids
    // of the xcorr studies
    params[-(i + 1)] = [record_id, "", study1];
  }

  int ME_ranks[];
  foreach r_rank, i in r_ranks
  {
    ME_ranks[i] = toint(r_rank);
  }

  assert(size(ME_ranks) == size(params), "Number of ME ranks must equal number of xcorrs");
  int keys[] = sort_keys(params);

  int modulo_prio = size(ME_ranks);
  foreach idx, r in keys
  {
    string ps[] = params[idx];
    int rank = ME_ranks[r];
    // initial priority, modulo priority, rank, record_id, feature file name, study1 name
    start(-(r + 1), modulo_prio, rank, ps[0], ps[1], ps[2]);
  }

}
