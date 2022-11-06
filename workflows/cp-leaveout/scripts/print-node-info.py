# PRINT NODE INFO PY

import argparse
import os
import pickle
import sys

from Node import Node
from utils import fail

parser = argparse.ArgumentParser(description="Print Node info stats")
parser.add_argument("directory", help="The experiment directory (EXPID)")

args = parser.parse_args()

node_pkl = args.directory + "/node-info.pkl"

try:
    with open(node_pkl, "rb") as fp:
        data = pickle.load(fp)
except IOError as e:
    fail(e, os.EX_IOERR, "Could not read: " + node_pkl)

# Raw data printing:
# print(len(data))
# print(data)

# Print the node info!
count = 0
earlies = 0
for node in data.values():
    print(node.str_table())
    count += 1
    if node.stopped_early:
        earlies += 1

print("print-node-info: %i/%i runs stopped early." % (count, earlies))
