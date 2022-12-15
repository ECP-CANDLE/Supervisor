import sys

import numpy as np
from scipy.stats import ttest_ind


# Could be used for NT3 (f(row) -> binary)
# Use t-test to select features that are discriminative between two sample classes
# data: an array, where rows are samples and columns are features (e.g., RNA expression row)
# label: a binary variable vector indicating the class labels. Its length is the same as the number
#       of rows in data. (e.g., normal or tumor)
# cutoff: a positive number for selecting predictive features. If cutoff < 1, this function
#       selects features with p-values <= cutoff. If cutoff >= 1, it must be an integer
#       indicating the number of features to be selected based on p-value.
# Returns a list of indices of the selected features.
def ttest_FS(data, label, cutoff):
    unique_label = list(set(label))
    if len(unique_label) != 2:
        print("T-test feature selection needs two sample classes")
        return None
    id0 = np.where(label == unique_label[0])[0]
    id1 = np.where(label == unique_label[1])[0]
    if len(id0) < 3 or len(id1) < 3:
        print(
            "T-test feature selection requires every sample class has at least 3 samples"
        )
        return None
    t, p = ttest_ind(a=data[id0, :], b=data[id1, :], axis=0, equal_var=False)
    if cutoff < 1:
        fid = np.where(p <= cutoff)[0]
    else:
        fid = sorted(range(len(p)), key=lambda x: p[x])[:int(cutoff)]
    return sorted(fid)


# For drug response regression (f(row) -> real)
# Use Pearson correlation coefficient to select predictive features for regression.
# data: an array, where rows are samples and columns are features
# target: a vector of real numbers indicating the regression target. Its length is the same as the
#       number of rows in data.
# cutoff: a positive number for selecting predictive features. If cutoff < 1, this function selects
#       the features with an absolute correlation coefficient >= cutoff. If cutoff >= 1, it must be an
#       integer indicating the number of features to be selected based on absolute correlation coefficient.
# Returns a list of indices of the selected features.
def correlation_FS(data, target, cutoff):
    cor = np.corrcoef(
        np.vstack((np.transpose(data), np.reshape(target, (1, len(target))))))
    cor = abs(cor[:-1, -1])
    if cutoff < 1:
        fid = np.where(cor >= cutoff)[0]
    else:
        fid = sorted(range(len(cor)), key=lambda x: cor[x],
                     reverse=True)[:int(cutoff)]
    return sorted(fid)


# Use the COXEN approach to select the features that are generalizable between data1 and data2.
# data1: an array, where rows are samples and columns are features
# data2: an array, where rows are samples and columns are features. data1 and data2 should have an equal
#       number of features. The features in data1 and data2 should match.
# cutoff: a positive number for selecting generalizable features. If cutoff < 1, this function selects
#       the features with a correlation coefficient >= cutoff. If cutoff >= 1, it must be an
#       integer indicating the number of features to be selected based on correlation coefficient.
# Returns a list of indices of the selected features.
def COXEN_FS(data1, data2, cutoff):
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
        fid = sorted(range(num), key=lambda x: cor[x],
                     reverse=True)[:int(cutoff)]
    return sorted(fid)


numF = 10  # Number of features
numS = 50  # Number of samples to be multiplied by 2
data1 = np.random.randn(numF, numS)
for i in range(numF):
    data1[i, :] = data1[i, :] + i / 5
data2 = np.random.randn(numF, numS)
data1 = np.hstack((data1, data2))
data1 = np.transpose(data1)
label = np.array([0 for i in range(numS)] + [1 for i in range(numS)])
data3 = np.random.randn(numF, int(numS / 2))
for i in range(numF):
    data3[i, :] = data3[i, :] + i / 5
data4 = np.random.randn(numF, int(numS / 2))
data3 = np.hstack((data3, data4))
data3 = np.transpose(data3)

idd = ttest_FS(data1, label, 0.1)
print(idd)
idd = ttest_FS(data1, label, 1)
print(idd)
idd = ttest_FS(data1, label, 3)
print(idd)

idd = correlation_FS(data1, label, 0.5)
print(idd)
idd = correlation_FS(data1, label, 1)
print(idd)
idd = correlation_FS(data1, label, 3)
print(idd)

idd = COXEN_FS(data1, data3, 0.5)
print(idd)
idd = COXEN_FS(data1, data3, 1)
print(idd)
idd = COXEN_FS(data1, data3, 3)
print(idd)
