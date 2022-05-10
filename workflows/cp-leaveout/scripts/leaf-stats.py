# LEAF STATS PY

import argparse, os, sys

import pandas as pd

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

columns = [ "CELL", "NODE", "POINTS", "EPOCHS", "MAE", "R2", "VAL_LOSS",
            "EARLY", "HO_MSE", "HO_MAE", "HO_R2" ]

df = pd.DataFrame(columns=columns)

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


class MatcherHoldoutMSE(utils.Matcher):

    def __init__(self):
        super(MatcherHoldoutMSE, self).__init__(".*   mse:.*")
        self.reset()

    def run(self, line):
        tokens = line.split()
        self.ho_mse = tokens[3]

    def reset(self):
        self.ho_mse = "0"

class MatcherHoldoutMAE(utils.Matcher):

    def __init__(self):
        super(MatcherHoldoutMAE, self).__init__(".*   mae:.*")
        self.reset()

    def run(self, line):
        tokens = line.split()
        self.ho_mae = tokens[3]

    def reset(self):
        self.ho_mae = "0"

class MatcherHoldoutR2(utils.Matcher):

    def __init__(self):
        super(MatcherHoldoutR2, self).__init__(".*   r2:.*")
        self.reset()

    def run(self, line):
        tokens = line.split()
        self.ho_r2 = tokens[3]

    def reset(self):
        self.ho_r2 = "0"


matcherPoints = MatcherPoints()
matcherStats  = MatcherStats()
matcherEarly  = MatcherEarly()
matcherHO_MSE = MatcherHoldoutMSE()
matcherHO_MAE = MatcherHoldoutMAE()
matcherHO_R2  = MatcherHoldoutR2()
grepper = utils.Grepper([matcherPoints, matcherStats, matcherEarly,
                         matcherHO_MSE, matcherHO_MAE, matcherHO_R2])

for node in nodes:
    cell = nodes[node]
    log = f"{args.directory}/run/{node}/save/python.log"
    grepper.grep(log)
    newrow = pd.DataFrame({
        "CELL"     : [cell],
        "NODE"     : [node],
        "POINTS"   : [matcherPoints.points],
        "EPOCHS"   : [matcherStats.epochs],
        "MAE"      : [matcherStats.mae],
        "R2"       : [matcherStats.r2],
        "VAL_LOSS" : [matcherStats.val_loss],
        "EARLY"    : [matcherEarly.early],
        "HO_MSE"   : [matcherHO_MSE.ho_mse],
        "HO_MAE"   : [matcherHO_MAE.ho_mae],
        "HO_R2"    : [matcherHO_R2 .ho_r2]
    })
    df = pd.concat([df, newrow], ignore_index=True)
    grepper.reset()

print(df.to_string())
