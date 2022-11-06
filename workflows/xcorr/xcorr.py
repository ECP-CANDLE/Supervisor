import os

import numpy as np


def correlation_feature_selection(data, targets, labels, cutoff):
    """Use Pearson correlation coefficient to select predictive features for
    regression.

    :param data: an data table, where rows are samples and columns are features
    :param label: sample labels of data, which match with targets
    :param targets: a vector of real numbers indicating the regression targets, with a length the same as labels.
    :param cutoff: a positive number for selecting predictive features. If cutoff < 1, this function selects
       the features with an absolute correlation coefficient >= cutoff. If cutoff >= 1, it must be an
       integer indicating the number of features to be selected based on absolute correlation coefficient.
    :returns a list of indices of the selected features.
    """

    batchSize = 100
    numBatch = int(np.ceil(data.shape[1] / batchSize))
    cor = np.empty((data.shape[1], 1))
    for i in range(numBatch):
        startIndex = i * batchSize
        endIndex = min((i + 1) * batchSize, data.shape[1])
        cor_i = np.corrcoef(
            np.vstack((
                np.transpose(
                    data.iloc[:, startIndex:endIndex].loc[labels, :].values),
                np.reshape(targets, (1, len(targets))),
            )))
        cor[startIndex:endIndex, 0] = abs(cor_i[:-1, -1])
    if cutoff < 1:
        gid = np.where(cor >= cutoff)[0]
    else:
        gid = np.argsort(-cor[:, 0])[:int(cutoff)]

    return gid


def cross_correlation_feature_selection(data1, data2, cutoff):
    """Use the COXEN approach to select the features that are generalizable
    between data1 and data2. data1 and data2 should have an equal number of
    features. The features in data1 and data2 should match.

    :param data1: an array, where rows are samples and columns are features
    :param data2: an array, where rows are samples and columns are features.
    :param cutoff: a positive number for selecting generalizable features. If cutoff < 1, this function selects
            the features with a correlation coefficient >= cutoff. If cutoff >= 1, it must be an
            integer indicating the number of features to be selected based on correlation coefficient.
    :returns: a list of indices of the selected features.
    """
    cor1 = np.corrcoef(np.transpose(data1))
    cor2 = np.corrcoef(np.transpose(data2))
    num = data1.shape[1]
    cor = []
    for i in range(num):
        cor.append(
            np.corrcoef(
                np.vstack((
                    list(cor1[:i, i]) + list(cor1[(i + 1):, i]),
                    list(cor2[:i, i]) + list(cor2[(i + 1):, i]),
                )))[0, 1])
    cor = np.array(cor)
    if cutoff < 1:
        fid = np.where(cor >= cutoff)[0]
    else:
        fid = np.argsort(-cor)[:int(cutoff)]
    return sorted(fid)
