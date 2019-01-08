import numpy as np
import os


def compute_feature_correlationf(study1_f, study2_f, cutoff, delimiter='\t'):
    """ 
    Use the COXEN approach to select the features that are generalizable between 
    the data in study1_f and study2_f. study1_f and study2_f should have an equal number 
    of features. The features in study1_f and study2_f should match.
    
    :param study1_f: a csv file, where rows are samples and columns are features
    :param study2_f: a csv file, where rows are samples and columns are features. 
    :param cutoff: a positive number for selecting generalizable features. If cutoff < 1, this function selects
            the features with a correlation coefficient >= cutoff. If cutoff >= 1, it must be an
            integer indicating the number of features to be selected based on correlation coefficient.
    :returns: a list of indices of the selected features.
    """
    
    data1 = np.loadtxt(study1_f, delimiter=delimiter)
    data2 = np.loadtxt(study2_f, delimiter=delimiter)
    return compute_feature_correlation(data1, data2, cutoff)
    

def compute_feature_correlation(data1, data2, cutoff):
    """ 
    Use the COXEN approach to select the features that are generalizable between data1 and data2.
    data1 and data2 should have an equal number of features. The features in data1 and data2 should 
    match.
    
    :param data1: an array, where rows are samples and columns are features
    :param data2: an array, where rows are samples and columns are features. 
    :param cutoff: a positive number for selecting generalizable features. If cutoff < 1, this function selects
            the features with a correlation coefficient >= cutoff. If cutoff >= 1, it must be an
            integer indicating the number of features to be selected based on correlation coefficient.
    :returns: a list of indices of the selected features.
    """

    # TODO pickle or save the cross correlation matrices
    # if these are time consuming to compute
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
        fid = sorted(range(num), key=lambda x: cor[x], reverse=True)[:int(cutoff)]
    return sorted(fid)
