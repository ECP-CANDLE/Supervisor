
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

string cache_dir = argv("cache_dir");
string xcorr_data_dir = argv("xcorr_data_dir");
string gpus = argv("gpus", "");

string exp_id = argv("exp_id");
int benchmark_timeout = toint(argv("benchmark_timeout", "-1"));

string site = argv("site");

string update_param_template =
"""
import json

vals = json.loads('%s')
params = {}
params['epochs'] = vals['epochs']
params['batch_size'] = vals['batch_size']
params['preprocess_rnaseq'] = 'combat'
study1 = vals['study1']
params['train_sources'] = study1

cache_dir = '%s'

if 'study2' in vals:
  study2 = vals['study2']
  cutoff = vals['cutoff']
  prefix = '{}_{}_{}_features'.format(study1, study2, cutoff)
  params['cell_feature_subset_path'] = '%s/{}.txt'.format(prefix)
  params['cache'] = '{}/{}_cache'.format(cache_dir, prefix)
  export_name = '{}_{}'.format(study1, study2)

else:
  params['use_landmark_genes'] = True
  params['cache'] = '{}/{}_cache'.format(cache_dir, study1)
  export_name = study1

params['export_data'] = '{}/{}.h5'.format(cache_dir, export_name)

gpus = '%s'
if len(gpus) > 0:
  params['gpus'] = gpus.replace(',', ' ')

params['save_path'] = '%s'
params['cp'] = True


params_json = json.dumps(params)
""";


main() {
  file json_input = input(argv("f"));
  string lines[] = file_lines(json_input);
  foreach params,i in lines {
    string instance = "%s/run/%i/" % (turbine_output, i);
    //make_dir(instance) => {
    param_code = update_param_template % (params, cache_dir, xcorr_data_dir, gpus, instance);
      updated_param = python_persist(param_code, "params_json");
    obj(updated_param, int2string(i));
    //}
  }
}

