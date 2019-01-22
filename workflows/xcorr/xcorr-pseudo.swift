
for study 1 in set of studies
  for study 2 in set of studies
    if study 1 not equal study 2
      for cutoffs in set of cutoffs
        gene_features_file = compute correlations (study1, study2, correlation_cutoff, cross_correlation_cutoff)
        log(study1, study2, correlation_cutoff, cross_correlation_cutoff, gene_features_file)
        log(contents of gene_features_file: list of gene names)
        run Uno, passing gene_features_file via --feature_subset_path
        

compute correlations(study1, study2, correlation_cutoff, cross_correlation_cutoff):
  cf. uno_xcorr.coxen_feature_selection:
    * source selection by study will generate set of cell lines (samples) to be used
    * COXEN correlation based on the selected samples, to select best N gene features between 
      the two studies
    * write gene features to file


Studies:  'CCLE', 'CTRP', 'gCSI', 'GDSC', 'NCI60'

Possible cutoff tuples from Yitan:

cutoffCorrelation=200, cutoffCrossCorrelation=100
cutoffCorrelation=100, cutoffCrossCorrelation=50
cutoffCorrelation=400, cutoffCrossCorrelation=200
cutoffCorrelation=200, cutoffCrossCorrelation=50
cutoffCorrelation=400, cutoffCrossCorrelation=50
cutoffCorrelation=400, cutoffCrossCorrelation=100



