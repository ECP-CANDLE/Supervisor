
# FIND LOSS INCREASES PY

# Brettin email 2019-12-18:
# Analysis 2: a list of validation samples,
# that when added to the training samples,
# cause the performance of the node/model to decrease.

import argparse, os, pickle, sys

from Node import Node
from utils import abort

filename = "node-info"

parser = argparse.ArgumentParser(description='Finds loss increases.')
parser.add_argument('directory',
                    help='The experiment directory (EXPID)')
parser.add_argument('--filename', '-f', default='node-info',
                    help='Change the node pkl file name')

args = parser.parse_args()

node_pkl = args.directory + "/" + args.filename + ".pkl"

try: 
    with open(node_pkl, 'rb') as fp:
        # This is a dict ("node_id" -> Node)
        data = pickle.load(fp)
except IOError as e:
    abort(e, os.EX_IOERR, "Could not read: " + node_pkl)

val_loss_worst = 0    
val_loss_best  = 1000
    
increases = []
total     = 0
for node_id in data.keys():
    parent_id = node_id[0:-2] # "1.2.3" -> "1.2"
    if len(parent_id) == 1: # stage=1
        continue
    current = data[node_id]
    parent  = data[parent_id]
    current.val_loss_delta = current.val_loss - parent.val_loss
    if current.val_loss_delta > 0:
        increases.append(current)
    if current.val_loss > val_loss_worst: val_loss_worst = current.val_loss
    if current.val_loss < val_loss_best:  val_loss_best  = current.val_loss
    total += 1

fraction = 100.0 * len(increases) / total
print("increases/total = %i / %i %02.f%%" % (len(increases), total, fraction))

print("val_loss_worst: %f" % val_loss_worst)
print("val_loss_best:  %f" % val_loss_best)

increases.sort(key=Node.get_val_loss_delta)
stopped_early = 0
for i in increases:
    # print("%f %-14s %r" % (i.val_loss_delta, i.id, i.stopped_early))
    if i.stopped_early: stopped_early += 1

def print_delta(prefix, node):
    print(prefix, str(node), "delta: %f" % node.val_loss_delta,
          node.stopped_early)
    
worst = increases[-1]
print_delta("worst:    ", worst)

n_01p = int(len(increases) / 100) # Worst 1 percentile
worst_01p = increases[-n_01p]
print_delta("worst  1%:", worst_01p)

n_10p = int(len(increases) / 10) # Worst 10 percentile
worst_10p = increases[-n_10p]
print_delta("worst 10%:", worst_10p)

print("increases that stopped early: %i" % stopped_early)
