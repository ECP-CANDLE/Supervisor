#!/usr/bin/env python3

# STAGE AVG PY
# Reports the average value for each stat by stage
# First extract the stats with ./extract-stats.sh
# Then provide stats.txt on stdin here

import sys

# Read the header, obtain the stat labels (R2, MSE, MAE)
line = sys.stdin.readline()
tokens = line.split()
data = {}
labels = []
for token in tokens[3:]:
    labels.append(token)
    data[token] = {}
message = " ".join(data.keys())
print("# stats: " + message)

# Read the main data: put in dict:
# Structure: data[label][stage] = [list of values]
while True:
    line = sys.stdin.readline()
    if len(line) == 0:
        break
    tokens = line.split()
    stage, run = tokens[0:2]
    # print(stage, run)
    offset = 2
    for index in range(0,len(labels)):
        label = labels[index]
        if stage not in data[label]:
            data[label][stage] = []
        data[label][stage].append(tokens[offset+index])

# Debug dump of all data:
# print(data)

def avg(L):
    s = 0.0
    for v in L:
        s += float(v)
    return s / len(L)

def mean_confidence_interval(data, confidence=0.95):
    import numpy as np
    import scipy.stats
    """ Cf. https://stackoverflow.com/questions/15033511/compute-a-confidence-interval-from-sample-data """
    data = list(map(float, data))
    a = 1.0 * np.array(data)
    n = len(a)
    m, se = np.mean(a), scipy.stats.sem(a)
    h = se * scipy.stats.t.ppf((1 + confidence) / 2., n-1)
    c = 100.0 * h / m # Interval scaled to mean
    return m, h, c

# Average each data[label][stage] and report
print("# %-5s %-6s AVG" % ("STAT", "STAGE"))
for label in labels:
    for stage in data[label].keys():
        # a = avg(data[label][stage])
        m, h, c = mean_confidence_interval(data[label][stage])
        print("  %-5s %-6s %0.6f±%0.6f (%2.f%%)" % (label, stage, m, h, c))
