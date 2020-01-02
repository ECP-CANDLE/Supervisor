
# WORKFLOW STATS PY

import argparse, math, os, pickle, sys

from Node import Node
from utils import fail

parser = argparse.ArgumentParser(description='Print workflow total stats')
parser.add_argument('directory',
                    help='The experiment directory (EXPID)')

args = parser.parse_args()

node_pkl = args.directory + "/node-info.pkl"

try:
    with open(node_pkl, 'rb') as fp:
        data = pickle.load(fp)
except IOError as e:
    fail(e, os.EX_IOERR, "Could not read: " + node_pkl)

# print(data)

class Epochs:
    def __init__(self):
        self.data = {}
    def add(self, stage, n):
        if stage not in self.data:
            self.data[stage] = []
        self.data[stage].append(n)
    def avg(self, stage):
        total = 0
        for n in self.data[stage]:
            total += n
        return total / len(self.data[stage])

epochs = Epochs()
count = 0   # Total Nodes
steps = 0   # Training steps
tm_s  = 0.0 # Total training time
for node in data.values():
    count += 1
    steps += node.steps
    tm_s  += node.time
    epochs.add(node.stage, node.epochs_actual)

tm_m = tm_s / 60
tm_h = tm_m / 60

print("count:     %i" % count)
print("steps:     %i" % steps)
print("steps (K): %i" % round(steps / (1000.0)))

print("time (s):  %11.3f " % tm_s)
print("time (m):  %11.3f " % tm_m)
print("time (h):  %10.2f " % tm_h)

for key in epochs.data.keys():
    print("avg: %i %0.2f" % (key, epochs.avg(key)))
