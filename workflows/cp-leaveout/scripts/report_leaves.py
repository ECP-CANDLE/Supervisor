
# REPORT LEAVES PY

import argparse, os, pickle, sys

from Node import Node
from utils import fail

parser = argparse.ArgumentParser(description=
                                 'Report nodes with no children.')
parser.add_argument('directory',
                    help='The experiment directory (EXPID)')

args = parser.parse_args()

node_pkl = args.directory + "/node-info.pkl"

try:
    with open(node_pkl, 'rb') as fp:
        data = pickle.load(fp)
except IOError as e:
    fail(e, os.EX_IOERR, "Could not read: " + node_pkl)

nodes  = data.keys()
leaves = data.copy()

for node in nodes:
    parent = node[0:-2]
    if parent in leaves:
        print("drop: " + parent)
        del leaves[parent]

results = list(leaves.keys())
results.sort()

for leaf in results:
    print(leaf)
