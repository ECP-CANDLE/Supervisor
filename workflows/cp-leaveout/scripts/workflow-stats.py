
# WORKFLOW STATS PY

import argparse, math, os, pickle, sys

from Node import Node
from utils import fail

parser = argparse.ArgumentParser(description='Print workflow total stats')
parser.add_argument('directory',
                    help='The experiment directory (EXPID)')

args = parser.parse_args()

if not os.path.isdir(args.directory):
    fail("No such directory: " + args.directory)

node_pkl = args.directory + "/node-info.pkl"

try:
    with open(node_pkl, 'rb') as fp:
        data = pickle.load(fp)
except IOError as e:
    fail(e, os.EX_IOERR, "Could not read: " + node_pkl)

# print(data)

class Statter:
    '''
    Compute states for some quantity (epochs_actual, stops, val_loss)
    by stage
    '''
    def __init__(self, name=None):
        self.data = {}
        self.name = name

    def add(self, stage, n):
        if stage not in self.data:
            self.data[stage] = []
        self.data[stage].append(n)

    def total(self, stage):
        result = 0
        for n in self.data[stage]:
            result += n
        return result

    def avg(self, stage):
        total = self.total(stage)
        return total / len(self.data[stage])

    def report_avg(self):
        keys = list(self.data.keys())
        keys.sort()
        print("%s: avg" % self.name)
        for key in keys:
            print("%i %0.2f" % (key, self.avg(key)))


epochs = Statter("epochs by stage")
stops  = Statter("stops  by stage")
count = 0   # Total Nodes
steps = 0   # Training steps
tm_s  = 0.0 # Total training time
for node in data.values():
    count += 1
    steps += node.steps
    tm_s  += node.time
    epochs.add(node.stage, node.epochs_actual)
    stops .add(node.stage, node.stopped_early)

tm_m = tm_s / 60
tm_h = tm_m / 60

print("count:     %i" % count)
print("steps:     %i" % steps)
print("steps (K): %i" % round(steps / (1000.0)))

print("time (s):  %11.3f " % tm_s)
print("time (m):  %11.3f " % tm_m)
print("time (h):  %10.2f " % tm_h)

print("")
epochs.report_avg()

print("")
stops.report_avg()
