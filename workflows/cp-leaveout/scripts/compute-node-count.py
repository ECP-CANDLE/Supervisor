
# COMPUTE NODE COUNT PY
# Simply calculate the node count

# These are the workflow parameters:
N = 4
S = 5

total = 0
current = 1 # Number of nodes in current stage
for stage in range(0, S):
    current *= 4
    print("%i: current: %4i" % (stage, current))
    total += current
    print("%i: total:   %4i" % (stage, total))
