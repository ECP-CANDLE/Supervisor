
import files;
import io;
import python;

string studies[] = file_lines(input("studies.txt"));
string rna_seq_data = "./test_data/combined_rnaseq_data_lincs1000_combat.bz2";
string drug_response_data = "./test_data/rescaled_combined_single_drug_growth_100K";
int cutoffs[][] = [[200, 100],
                   [100, 50],
                   [400, 200],
                   [200, 50],
                   [400, 50],
                   [400, 100]];


string xcorr_template =
"""
import uno_xcorr

study1 = '%s'
study2 = '%s'
correlation_cutoff = %d
cross_correlation_cutoff = %d
features_file = '%s'
uno_xcorr.coxen_feature_selection(study1, study2, correlation_cutoff, cross_correlation_cutoff, output_file=features_file)
""";

string init_template =
"""
import uno_xcorr
from xcorr_db import xcorr_db

DB = xcorr_db('xcorr.db')
DB.read_feature_names()
DB.read_study_names()
rna_seq_data = '%s'
drug_response_data = '%s'

uno_xcorr.init_uno_xcorr(rna_seq_data, drug_response_data)
""";


string log_corr_template =
"""
# filename, study1, study2, cutoff_corr, cutoff_xcorr
DB.insert_xcorr_record(filename='%s',
                       studies=[ '%s', '%s'],
                       features=[],
                       cutoff_corr=%f, cutoff_xcorr=%f)
DB.commit()
""";

init_xcorr() =>
{
  foreach study1 in studies
  {
    foreach study2 in studies
    {
      if (study1 != study2)
      {
        foreach cutoff in cutoffs
        {
          printf("Study1: %s, Study2: %s, cc: %d, ccc: %d", study1, study2, cutoff[0], cutoff[1]);
          fname = "./test_data/%s_%s_%d_%d_features.txt" % (study1, study2, cutoff[0], cutoff[1]);
          compute_feature_correlation(study1, study2, cutoff[0], cutoff[1], fname);
        }
      }
    }
  }
}

(void o)init_xcorr() {
  init_code = init_template % (rna_seq_data, drug_response_data);
  python_persist(init_code, "''") =>
  o = propagate();
}

compute_feature_correlation(string study1, string study2, int corr_cutoff, int xcorr_cutoff, string features_file)
{
  log_code = log_corr_template % (features_file, study1, study2, corr_cutoff, xcorr_cutoff);
  python_persist(log_code, "''");
  code = xcorr_template % (study1, study2, corr_cutoff, xcorr_cutoff, features_file);
  python_persist(code, "''");
}


// Selected features = best N features between A and B based on correlation
