
import files;
import io;
import python;

file studies[] = glob("test_data/data*.tsv");

string xcorr_template = 
"""
import xcorr

fids = xcorr.compute_feature_correlationf('%s', '%s', %i)
""";

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
      compute_feature_correlation(study1, study2);
    }
  }
}

compute_feature_correlation(file study1, file study2)
{
  code = xcorr_template % (filename(study1), filename(study2), 3);
  string fids = python_persist(code, "str(fids)");
  printf(fids);
}


// Selected features = best N features between A and B based on correlation
