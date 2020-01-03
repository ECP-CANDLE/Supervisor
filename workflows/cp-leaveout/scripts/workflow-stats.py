
# WORKFLOW STATS PY

import argparse, math, os, pickle, sys

from Node import Node
from utils import fail

parser = argparse.ArgumentParser(description='Print workflow total stats')
parser.add_argument('directory',
                    help='The experiment directory (EXPID)')
parser.add_argument('--percentiles', action='store_true',
                    help='If given, run percentiles analysis')
parser.add_argument('--token', default=None,
                    help='User-readable naming token')

args = parser.parse_args()

if not os.path.isdir(args.directory):
    fail("No such directory: " + args.directory)

if args.token == None:
    args.token = os.path.basename(args.directory)

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
    def __init__(self, name=None, token=None):
        self.data = {}
        self.name = name
        self.token = token

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

    def percentile(self, stage, percentile):
        self.data[stage].sort(reverse=True)
        n = len(self.data[stage])
        i = round(percentile * n) - 1
        if i < 0: i = 0
        return self.data[stage][i]

    def report_avg(self):
        report = self.string_avg()
        print(report)

    def string_avg(self):
        keys = list(self.data.keys())
        keys.sort()
        result = "# %s: avg\n" % self.name
        for key in keys:
            result += "%i %0.2f\n" % (key, self.avg(key))
        return result

    def string_percentile(self, percentile):
        keys = list(self.data.keys())
        keys.sort()
        result = "# %s: %s: percentile %0.2f\n" % \
                 (self.token, self.name, percentile)
        for key in keys:
            result += "%i %0.4f\n" % (key, self.percentile(key, percentile))
        return result

epochs = Statter("epochs   by stage", token=args.token)
stops  = Statter("stops    by stage", token=args.token)
losses = Statter("val_loss by stage", token=args.token)
times  = Statter("times    by stage", token=args.token)
count = 0   # Total Nodes
steps = 0   # Training steps
tm_s  = 0.0 # Total training time
best_val_loss = Node(id="BEST")
best_val_loss.val_loss = 1000
for node in data.values():
    count += 1
    steps += node.steps
    tm_s  += node.time
    epochs.add(node.stage, node.epochs_actual)
    stops .add(node.stage, node.stopped_early)
    losses.add(node.stage, node.val_loss)
    times.add(node.stage,  node.total_time(data))
    if node.val_loss < best_val_loss.val_loss: best_val_loss = node

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

stops.report_avg()

def do_percentiles():
    for percentile in [0.99, 0.75, 0.50, 0.25, 0.10]:
        report = losses.string_percentile(percentile)
        filename = 'percentile-%s-%0.2f.data' % \
            (args.token, percentile)
        with open(filename, 'w') as fp:
            fp.write(report)

if args.percentiles:
    do_percentiles()

print("best_val_loss: %s %0.2f hours" %
      (str(best_val_loss), (best_val_loss.total_time(data)/3600)))
