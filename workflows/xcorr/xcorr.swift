
import files;
import io;
import python;

file studies[] = glob("studies/*.data");

// for study 1 in set of studies
//   for study 2 in set of studies
//     if study 1 not equal study 2
//       compute correlations
foreach study1 in studies
{
  foreach study2 in studies
  {
    printf("%s ?= %s", filename(study1), filename(study2));
    if (filename(study1) != filename(study2))
    {
      compute_correlations(study1, study2);
    }
  }
}

// compute correlations:
//   compute feature cross correlation matrix in study 1
//   compute feature cross correlation matrix in study 2
//   compute feature correlation between study 1 and study 2
compute_correlations(file study1, file study2)
{
  wait (compute_feature_cross_corellation_matrix(study1),
        compute_feature_cross_corellation_matrix(study2))
  {
    compute_feature_correlation(study1, study2);
  }
}

(string v)
compute_feature_cross_corellation_matrix(file study)
{
  v = python("from xcorr import *",
             "compute_feature_cross_corellation_matrix('%s')" %
             filename(study));
}

compute_feature_correlation(file study1, file study2)
{
  python("from xcorr import *",
         "compute_feature_corellation('%s', '%s')" %
         (filename(study1), filename(study2)));
}


// Selected features = best N features between A and B based on correlation
