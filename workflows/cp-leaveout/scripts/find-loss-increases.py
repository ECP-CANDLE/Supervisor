
# FIND LOSS INCREASES PY

# Brettin email 2019-12-18:
# Analysis 2: a list of validation samples,
# that when added to the training samples,
# cause the performance of the node/model to decrease.

import argparse, os, pickle, sys

from Node import Node
from utils import abort

parser = argparse.ArgumentParser(description='Finds loss increases.')
parser.add_argument('directory',
                    help='The experiment directory (EXPID)')

args = parser.parse_args()

node_pkl = args.directory + "/node-info.pkl"

try: 
    with open(node_pkl, 'rb') as fp:
        # This is a dict ("node_id" -> Node)
        data = pickle.load(fp)
except IOError as e:
    abort(e, os.EX_IOERR, "Could not read: " + node_pkl)

increases = 0
total     = 0
for node_id in data.keys():
    parent = node_id[0:-2] # "1.2.3" -> "1.2"
    if len(parent) == 1: # stage=1
        continue
    if data[node_id].val_loss > data[parent].val_loss:
        increases += 1
    total += 1

fraction = 100.0 * increases / total
print("increases/total = %i / %i %02.f%%" % (increases, total, fraction))
