# LEAF STATS PY

import argparse, os, sys

import utils

parser = argparse.ArgumentParser(description='Print leaf stats')
parser.add_argument('directory',
                    help='The experiment directory (EXPID)')
parser.add_argument('list',
                    help='The list of nodes to process')

args = parser.parse_args()

# Map from node "1.1.1.1.2.3" to cell line "CCLE.KMS11"
nodes = {}

with open(args.list, 'r') as fp:
    while True:
        line = fp.readline()
        if len(line) == 0: break
        tokens = line.split()
        node = tokens[0]
        cell = tokens[1]
        nodes[node] = cell

from collections import OrderedDict

headers = [ "CELL", "NODE", "POINTS", "EPOCHS", "MAE", "R2", "VAL_LOSS", "EARLY" ]
columns = OrderedDict()
for header in headers:
    columns[header] = []


class MatcherPoints(utils.Matcher):

    def __init__(self):
        super(MatcherPoints, self).__init__(".*Data points per epoch.*")
        self.reset()

    def run(self, line):
        tokens = line.split()
        # Remove trailing comma:
        self.points = tokens[11][0:-1]

    def reset(self):
        self.points = 0


class MatcherStats(utils.Matcher):

    def __init__(self):
        super(MatcherStats, self).__init__(".*loss:.*")
        self.reset()

    def run(self, line):
        tokens = line.split()
        # Remove trailing bracket or comma:
        self.epochs   = tokens[ 3][0:-1]
        self.mae      = tokens[ 7][0:-1]
        self.r2       = tokens[ 9][0:-1]
        self.val_loss = tokens[11][0:-1]

    def reset(self):
        self.epochs = 0
        self.mae = 0
        self.r2 = 0
        self.val_loss = 0


class MatcherEarly(utils.Matcher):

    def __init__(self):
        super(MatcherEarly, self).__init__(".*stopping: early.*")
        self.reset()

    def run(self, line):
        self.early = "1"

    def reset(self):
        self.early = "0"


matcherPoints = MatcherPoints()
matcherStats  = MatcherStats()
matcherEarly  = MatcherEarly()
grepper = utils.Grepper([matcherPoints, matcherStats, matcherEarly])

for node in nodes:
    cell = nodes[node]
    log = f"{args.directory}/run/{node}/save/python.log"
    grepper.grep(log)
    columns["CELL"]    .append(cell)
    columns["NODE"]    .append(node)
    columns["POINTS"]  .append(matcherPoints.points)
    columns["EPOCHS"]  .append(matcherStats.epochs)
    columns["MAE"]     .append(matcherStats.mae)
    columns["R2"]      .append(matcherStats.r2)
    columns["VAL_LOSS"].append(matcherStats.val_loss)
    columns["EARLY"]   .append(matcherEarly.early)
    grepper.reset()

utils.columnPrint(columns, "llrrrrrr")
