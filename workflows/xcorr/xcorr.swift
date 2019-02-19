
/*
  XCORR SWIFT
  Main cross-correlation workflow
*/

import files;
import io;
import python;
import unix;

printf("XCORR WORKFLOW");

string studies[] = file_lines(input("studies.txt"));
string preprocess_rnaseq = "combat";
string rna_seq_data = "./test_data/combined_rnaseq_data_lincs1000_%s.bz2" % preprocess_rnaseq;
string drug_response_data = "./test_data/rescaled_combined_single_drug_growth_100K";
int cutoffs[][] = [[200, 100],
                   [100, 50],
                   [400, 200],
                   [200, 50],
                   [400, 50],
                   [400, 100]];

app uno(file features, string study1)
{
  "./uno.sh" features study1 preprocess_rnaseq;
}

foreach study1 in studies
{
  foreach study2 in studies
  {
    if (study1 != study2)
    {
      foreach cutoff in cutoffs
      {
        printf("Study1: %s, Study2: %s, cc: %d, ccc: %d",
               study1, study2, cutoff[0], cutoff[1]);
        fname = "./test_data/%s_%s_%d_%d_features.txt" %
          (study1, study2, cutoff[0], cutoff[1]);
        file features<fname>;
        compute_feature_correlation(study1, study2, cutoff[0], cutoff[1], fname) =>
          features = touch();
        // train study1 using the specified features
        uno(features, study1);
      }
    }
  }
}

(void v)
compute_feature_correlation(string study1, string study2,
                            int corr_cutoff, int xcorr_cutoff,
                            string features_file)
{
  log_corr_template =
"""
from xcorr_db import xcorr_db, setup_db

global DB
DB = setup_db()

features = DB.scan_features_file('%s')
DB.insert_xcorr_record(studies=[ '%s', '%s' ],
                       features=features,
                       cutoff_corr=%d, cutoff_xcorr=%d)
""";

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

  log_code = log_corr_template % (features_file, study1, study2,
                                  corr_cutoff, xcorr_cutoff);

  xcorr_code = xcorr_template % (rna_seq_data, drug_response_data,
                                 study1, study2,
                                 corr_cutoff, xcorr_cutoff,
                                 features_file);

  python_persist(xcorr_code) =>
    python_persist(log_code) =>
    v = propagate();
}


// Selected features = best N features between A and B based on correlation
