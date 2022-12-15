# LOSS HISTOGRAM
# usage: python3 scripts/loss-histogram.py < $D/losses.txt

import sys

buckets = {}
for line in sys.stdin:
    tokens = line.split()
    i = len(tokens[0])
    if i not in buckets:
        buckets[i] = []
    buckets[i].append(float(tokens[1]))

L = list(buckets.keys())
L.sort()

for i in L:
    avg = sum(buckets[i]) / len(buckets[i])
    print("%i %0.6f" % (i, avg))

# For X054
# 3 0.023623
# 5 0.015583
# 7 0.012658
