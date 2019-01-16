import numpy as np
from scipy.stats import ttest_ind

import os


def ttest_feature_selection(data, labels, cutoff):
    """
    Use t-test to select features that are discriminative between two sample classes

    :param data: an array, where rows are samples and columns are features (e.g., RNA expression row)
    :param labels: a binary variable vector indicating the class labels, with length is 
        the same as the number of rows in data. (e.g., normal or tumor)
    :param cutoff: a positive number for selecting predictive features. If cutoff < 1, this function
       selects features with p-values <= cutoff. If cutoff >= 1, it must be an integer
       indicating the number of features to be selected based on p-value.
    :returns a list of indices of the selected features.
    """

    unique_label = list(set(labels))
    if len(unique_label) != 2:
        raise ValueError('T-test feature selection needs two sample classes')

    id0 = np.where(labels == unique_label[0])[0]
    id1 = np.where(labels == unique_label[1])[0]
    if len(id0) < 3 or len(id1) < 3:
        raise ValueError('T-test feature selection requires every sample class has at least 3 samples')
        
    _, p = ttest_ind(a=data[id0, :], b=data[id1, :], axis=0, equal_var=False)
    if cutoff < 1:
        fid = np.where(p <= cutoff)[0]
    else:
        fid = sorted(range(len(p)), key=lambda x: p[x])[:int(cutoff)]
    return sorted(fid)

def correlation_feature_selection(data, targets, cutoff):
    """
    Use Pearson correlation coefficient to select predictive features for regression.
    :param data: an array, where rows are samples and columns are features
    :param targets: a vector of real numbers indicating the regression targets, with length the same as the       number of rows in data.
    :param cutoff: a positive number for selecting predictive features. If cutoff < 1, this function selects
       the features with an absolute correlation coefficient >= cutoff. If cutoff >= 1, it must be an
       integer indicating the number of features to be selected based on absolute correlation coefficient.
    :returns a list of indices of the selected features.
    """

    cor = np.corrcoef(np.vstack((np.transpose(data), np.reshape(targets, (1, len(targets))))))
    cor = abs(cor[:-1, -1])
    if cutoff < 1:
        fid = np.where(cor >= cutoff)[0]
    else:
        fid = sorted(range(len(cor)), key=lambda x: cor[x], reverse=True)[:int(cutoff)]
    return sorted(fid)


def coxen_feature_selectionf(study1_f, study2_f, cutoff, delimiter='\t'):
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
    return coxen_feature_selection(data1, data2, cutoff)
    

def coxen_feature_selection(data1, data2, cutoff):
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
