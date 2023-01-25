# REPORT LRS PY

import argparse
import os
import pickle
import sys

from Node import Node
from utils import avg, fail

parser = argparse.ArgumentParser(description="Report learning rate for nodes.")
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
    print("%-14s %s %s" % (key,
                           Node.maybe_str_float(node.lr_first, "%0.6f"),
                           Node.maybe_str_float(node.lr_final, "%0.6f")))
