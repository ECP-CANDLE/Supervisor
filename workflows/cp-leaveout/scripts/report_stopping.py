# REPORT STOPPING PY

import argparse
import os
import pickle
import sys

from Node import Node
from utils import avg, fail

parser = argparse.ArgumentParser(description="Report nodes with no children.")
parser.add_argument("directory", help="The experiment directory (EXPID)")

args = parser.parse_args()

node_pkl = args.directory + "/node-info.pkl"

try:
    with open(node_pkl, "rb") as fp:
        data = pickle.load(fp)
except IOError as e:
    fail(e, os.EX_IOERR, "Could not read: " + node_pkl)

stages = {1: [], 2: [], 3: [], 4: [], 5: [], 6: []}

for key in data:
    # print(key)
    node = data[key]
    # print(data[node])
    print("%-14s %i %i" % (key, node.stage, node.epochs_actual))
    stages[node.stage].append(node.epochs_actual)
    # exit()

for i in range(1, 7):
    L = stages[i]
    a = avg(L)
    print("%i: %0.3f" % (i, a))

    # a = st
    # 1.3.2.4.2.4.1
