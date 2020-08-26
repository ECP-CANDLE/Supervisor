
# EPOCH TIME PY
# See epoch-time.sh

import datetime, sys, time

from Node import Node
from utils import fail

# Main data structure:
#      map from stage number to list of epoch times in seconds
stages = {}
for stage in range(1,6+1):
    stages[stage] = []

# Files processed:
progress = 0
total    = 0

node_current  = "NONE"
stage_current = -1
start_current = None

while True:

    line = sys.stdin.readline()

    if len(line) == 0: break    # EOF
    if len(line) == 1: continue # Blank line
    tokens = line.split()

    if tokens[0] == "epoch-time:":
        if tokens[1] == "node":
            node_current  = tokens[2]
            stage_current = int(len(node_current) / 2)
            start_current = None
            # print("node: " + node_current)
            # print("stage: " + str(stage_current))
            progress += 1
        elif tokens[1] == "total":
            total = int(tokens[2])
        else:
            assert(False)
        continue

    if tokens[2] == "UNO" and tokens[3] == "START":
        # This is a Keras restart: Reset the timer
        start_current = None

    if tokens[2] == "Epoch":
        ts = tokens[0] + " " + tokens[1]
        dt = datetime.datetime.strptime(ts, "%Y-%m-%d %H:%M:%S")
        if start_current == None:
            start_current = dt
            continue
        start = start_current.timestamp()
        stop  = dt           .timestamp()
        duration = stop - start
        # print("epoch complete: " + str(duration))
        start_current = dt
        stages[stage_current].append(duration)

for stage in range(1,6+1):
    n = len(stages[stage])
    if n == 0:
        avg = -1
    else:
        avg = sum(stages[stage]) / n
    print("stage %i count: %6i avg: %8.2f" % (stage, n, avg))
