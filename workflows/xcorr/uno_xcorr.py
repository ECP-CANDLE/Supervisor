import os

import xcorr
import uno_data

gene_df = None

def init_uno_xcorr(uno_args):
    """Initialize this package for xcorr and the Uno benchmark

    :param uno_args: a dictionary of args appropriate for calling
     uno_data.load_cell_rnaseq
    """
    ncols = uno_args['ncols']
    scaling = uno_args['scaling']
    use_landmark_genes = uno_args['use_landmark_genes']
    use_filtered_genes = uno_args['use_filtered_genes']
    preprocess_rnaseq = uno_args['preprocess_rnaseq']

    global gene_df
    gene_df = uno_data.load_cell_rnaseq(ncols=ncols, scaling=scaling, use_landmark_genes=use_landmark_genes,
        use_filtered_genes=use_filtered_genes, preprocess_rnaseq=preprocess_rnaseq)
    # extract the source prefix from the sample id
    gene_df['source'] = gene_df['Sample'].str.extract('^([^.]*)', expand=False)


def select_features(source='all'):
    """ Selects and returns a data frame from features whose 
    source is equal to the specified source. If source is 'all' then
    all features are returned. 

    :param source: a string specifing the source or 'all'.
    """

    if gene_df is None:
        raise ValueError("uno_xcorr is not initialized. Call init_uno_xcorr to initialize.")

    df = gene_df
    if source != 'all':
        df = df[df['source'] == source]
    
    df = df.drop(['source', 'Sample'], axis=1)

    return df


def compute_cross_correlation(source_1, source_2, cutoff, genes_file=None):
    df1 = select_features(source_1)
    df2 = select_features(source_2)
    fids = xcorr.compute_feature_correlation(df1.values, df2.values, cutoff)
    genes = list(df1.columns[fids])
    idx = genes[0].find('.')
    if idx >= 0:
        genes = [x[idx + 1 : ] for x in genes]
    
    if not genes_file is None:
        if not os.path.exists(os.path.dirname(genes_file)):
            os.makedirs(os.path.dirname(genes_file))
        with open(genes_file, 'w') as f_out:
            for g in genes:
                f_out.write('{}\n'.format(g))



    


    



