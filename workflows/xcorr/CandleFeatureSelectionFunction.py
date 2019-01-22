import numpy as np
import pandas as pd



# Use cross-correlation to select the features that are generalizable between data1 and data2.
# data1: an array, where rows are samples and columns are features
# data2: an array, where rows are samples and columns are features. data1 and data2 should have an equal
#       number of features. The features in data1 and data2 should match.
# cutoff: a positive number for selecting generalizable features. If cutoff < 1, this function selects
#       the features with a cross-correlation coefficient >= cutoff. If cutoff >= 1, it must be an
#       integer indicating the number of features to be selected based on cross-correlation coefficient.
# Returns a list of indices of the selected features.
def crossCorrelation_FS(data1, data2, cutoff):
    cor1 = np.corrcoef(np.transpose(data1))
    cor2 = np.corrcoef(np.transpose(data2))
    num = data1.shape[1]
    cor = []
    for i in range(num):
        cor.append(np.corrcoef(np.vstack((list(cor1[:i, i]) + list(cor1[(i + 1):, i]),
                   list(cor2[:i, i]) + list(cor2[(i + 1):, i]))))[0, 1])
    cor = np.array(cor)
    if cutoff < 1:
        fid = np.where(cor >= cutoff)[0]
    else:
        fid = np.argsort(-cor)[:int(cutoff)]
    return sorted(fid)



# Use COXEN approach to select predictive and generalizable genes for prediction.
# source1: the name of study 1, should be one of 'CCLE', 'CTRP', 'gCSI', 'GDSC', 'NCI60'
# source2: the name of study 2, should be one of 'CCLE', 'CTRP', 'gCSI', 'GDSC', 'NCI60'
# rnaSeqData: gene expression data following the format of combined_rnaseq_data_combat
# drugResponseData: drug response data following the format of rescaled_combined_single_drug_growth
# cutoffCorrelation: a positive number for selecting predictive genes. If cutoffCorrelation < 1, genes
#        whose absolute correlation coefficient with drug response >= cutoffCorrelation are considered for
#        selection. If cutoffCorrelation >= 1, it must be an integer indicating the number of genes with the largest
#        absolute correlation coefficients to be considered for selection.
# cutoffCrossCorrelation: a positive number for selecting generalizable genes. If cutoffCrossCorrelation < 1, genes
#        whose cross-correlation coefficient >= cutoffCrossCorrelation are selected. If cutoffCrossCorrelation >= 1,
#        it must be an integer indicating the number of genes to be selected based on cross-correlation coefficient.

def COXEN_FeatureSelection(source1, source2, rnaSeqData, drugResponseData, cutoffCorrelation=200, cutoffCrossCorrelation=100):
    # get rnaSeq data of source1 and source2
    source = np.array([i.split('.')[0] for i in rnaSeqData.index])
    data1 = rnaSeqData.iloc[np.where(source == source1)[0], :]
    data2 = rnaSeqData.iloc[np.where(source == source2)[0], :]

    # keep only drug response data of cell lines in data1
    drugResponseData = drugResponseData.iloc[np.where(drugResponseData.SOURCE == source1)[0], :]
    drugResponseData = drugResponseData.iloc[np.where(np.isin(drugResponseData.CELLNAME, data1.index))[0], :]

    # perform the first step of COXEN approach to select predictive genes. To avoid exceeding the memory limit,
    # the prediction power of genes (i.e. absolute correlation coefficient with drug response) is calculated in batches.
    batchSize = 100
    numBatch = int(np.ceil(data1.shape[1]/batchSize))
    cor = np.empty((data1.shape[1], 1))
    for i in range(numBatch):
        startIndex = i*batchSize
        endIndex = min((i+1)*batchSize, data1.shape[1])
        cor_i = np.corrcoef(np.vstack((np.transpose(data1.iloc[:, startIndex:endIndex].loc[drugResponseData.CELLNAME,
             :].values), np.reshape(drugResponseData.GROWTH.values, (1, drugResponseData.shape[0])))))
        cor[startIndex:endIndex, 0] = abs(cor_i[:-1, -1])
    if cutoffCorrelation < 1:
        gid1 = np.where(cor >= cutoffCorrelation)[0]
    else:
        gid1 = np.argsort(-cor[:, 0])[:int(cutoffCorrelation)]

    # keep only predictive genes for data1 and data2
    data1 = data1.iloc[:, gid1]
    data2 = data2.iloc[:, gid1]

    # perform the second step of COXEN approach to select generalizable genes among the predictive genes
    gid2 = crossCorrelation_FS(data1.values, data2.values, cutoffCrossCorrelation)

    # return the gene names
    return data1.columns[gid2]



# Load data.
rnaSeqData = pd.read_csv('/home/nick/Documents/repos/Benchmarks/Data/Pilot1/combined_rnaseq_data_lincs1000_combat', sep='\t', engine='c', na_values=['na', '-', ''],
                         header=0, index_col=0)
drugResponseData = pd.read_csv('/home/nick/Documents/repos/Benchmarks/Data/Pilot1/rescaled_combined_single_drug_growth', sep='\t', engine='c',
                               na_values=['na', '-', ''], header=0, index_col=None)

# Sample selection and filtering should be done here by selecting a part of drugResponseData or a part of rnaSeqData.
# The following line of code is just a example randomly selecting 10000 samples through subsetting drugResponseData.
drugResponseData = drugResponseData.iloc[np.random.permutation(drugResponseData.shape[0])[:10000], :]

selectedGenes = COXEN_FeatureSelection(source1='CTRP', source2='CCLE', rnaSeqData=rnaSeqData,
                       drugResponseData=drugResponseData, cutoffCorrelation=100, cutoffCrossCorrelation=50)
