import os
import pandas as pd
import numpy as np

import xcorr

gene_df = None
drug_df = None

def init_uno_xcorr(rna_seq_path, drug_response_path, drug_ids=None):
    """Initialize this package for xcorr and the Uno benchmark

    :param rna_seq_path: path to gene expression data following the format of 
        combined_rnaseq_data_combat
    :param drug_response_path: path to drug response data following the format of 
        rescaled_combined_single_drug_growth
    """

    global gene_df
    gene_df = pd.read_csv(rna_seq_path, compression='infer', sep='\t', engine='c', na_values=['na', '-', ''],
        header=0, index_col=0)
    gene_df['source'] = gene_df.index.str.extract('^([^.]*)', expand=False)
    
    global drug_df
    drug_df = pd.read_csv(drug_response_path, compression='infer', sep='\t', engine='c',
                na_values=['na', '-', ''], header=0, index_col=None)
    if drug_ids is not None:
        drug_df = drug_df[drug_df['DRUG_ID'].isin(drug_ids)]


def select_features(df, source_col, source='all'):
    """ Selects and returns a data frame from features whose 
    source is equal to the specified source. If source is 'all' then
    all features are returned. 

    :param source: a string specifing the source -- one of 'CCLE', 'CTRP', 'gCSI', 'GDSC', 'NCI60' 
        or 'all'.
    """

    df1 = df
    if source != 'all':
        df1 = df1[df1[source_col] == source]
    return df1


## TODO: add additional args / functions for additional sample selection
def coxen_feature_selection(source_1, source_2, correlation_cutoff, 
    cross_correlation_cutoff, drug_ids=None, output_file=None):

    df1 = select_features(gene_df, 'source', source_1)
    df1 = df1.drop(['source'], axis=1)
    df2 = select_features(gene_df, 'source', source_2)
    df2 = df2.drop(['source'], axis=1)

    dr_df = select_features(drug_df, 'SOURCE', source_1)
    if drug_ids is not None:
        dr_df = dr_df[dr_df['DRUG_ID'].isin(drug_ids)]

    # keep only drug response data of cell lines in data1
    dr_df = drug_df.iloc[np.where(np.isin(dr_df.CELLNAME, df1.index))[0], :]

    # perform the first step of COXEN approach to select predictive genes. To avoid exceeding the memory limit,
    # the prediction power of genes (i.e. absolute correlation coefficient with drug response) is calculated in batches.
    gid1 = xcorr.correlation_feature_selection(df1, dr_df.GROWTH.values, 
            dr_df.CELLNAME, correlation_cutoff)
    
    # keep only predictive genes for data1 and data2
    df1 = df1.iloc[:, gid1]
    df2 = df2.iloc[:, gid1]

    gid2 = xcorr.cross_correlation_feature_selection(df1.values, df2.values, 
        cross_correlation_cutoff)
    
    genes = df1.columns[gid2]
    if output_file is not None:
        with open(output_file, 'w') as f_out:
            for g in genes:
                f_out.write('{}\n'.format(g))

    return genes
