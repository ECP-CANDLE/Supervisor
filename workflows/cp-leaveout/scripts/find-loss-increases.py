
# FIND LOSS INCREASES PY

# Brettin email 2019-12-18:
# Analysis 2: a list of validation samples,
# that when added to the training samples,
# cause the performance of the node/model to decrease.

import argparse, os, pickle, sys

from Node import Node
from utils import append, avg, fail

STAGE_ANY = 0

parser = argparse.ArgumentParser(description='Finds loss increases.')
parser.add_argument('directory',
                    help='The experiment directory (EXPID)')
parser.add_argument('--filename', '-f',
                    default='node-info',
                    help='Change the node pkl file name')
parser.add_argument('--stage', '-S',
                    type=int,
                    default=STAGE_ANY,
                    help='Select the stage')
parser.add_argument('--token', '-T', default=None,
                    help='User-readable naming token')

args = parser.parse_args()

if args.token == None:
    args.token = os.path.basename(args.directory)

node_pkl = args.directory + '/' + args.filename + '.pkl'

try:
    with open(node_pkl, 'rb') as fp:
        # This is a dict ('node_id' -> Node)
        data = pickle.load(fp)
except IOError as e:
    fail(e, os.EX_IOERR, 'Could not read: ' + node_pkl)

# Artificial nodes for comparison:
node_worst = Node("WORST")
node_worst.val_loss = 0
node_best  = Node("BEST")
node_best.val_loss = 1000

if args.stage != STAGE_ANY:
    print("STAGE: %i" % args.stage)

# List of Nodes where val_loss increased:
increases = []
# Total Node count:
total = 0
for node_id in data.keys():
    parent_id = node_id[0:-2] # '1.2.3' -> '1.2'
    if len(parent_id) == 1: # stage=1
        continue
    current = data[node_id]
    parent  = data[parent_id]
    if not (args.stage == STAGE_ANY or args.stage == current.stage):
        continue
    current.val_loss_delta = current.val_loss - parent.val_loss
    if current.val_loss_delta > 0:
        increases.append(current)
    if current.val_loss > node_worst.val_loss: node_worst = current
    if current.val_loss < node_best.val_loss:  node_best  = current
    total += 1

if total == 0: fail('No matching Nodes found!')

fraction = 100.0 * len(increases) / total
print('increases/total = %i / %i (%02.f%%)' % (len(increases), total, fraction))

file_increases = "increases-%s.data" % args.token
append(file_increases, "%i %5.1f" % (args.stage, fraction))

print('worst val_loss: ' + str(node_worst))
print('best  val_loss: ' + str(node_best))

print('DELTAS:')

increases.sort(key=Node.get_val_loss_delta)
stopped_early = 0
for i in increases:
    # print('%f %-14s %r' % (i.val_loss_delta, i.id, i.stopped_early))
    if i.stopped_early: stopped_early += 1

def print_delta(prefix, node):
    print(prefix, str(node), 'delta: %f' % node.val_loss_delta)

worst = increases[-1]
print_delta('worst:    ', worst)

n_01p = int(round(len(increases) / 100)) # Worst 1 percentile
if n_01p == 0: n_01p = 1
worst_01p = increases[-n_01p]
print_delta('worst  1%:', worst_01p)

n_10p = int(round(len(increases) / 10)) # Worst 10 percentile
if n_10p == 0: n_10p = 1
worst_10p = increases[-n_10p]
print_delta('worst 10%:', worst_10p)

print('increases that stopped early: %i' % stopped_early)

values_increase = []
values_val_loss = []
for node in increases:
    values_increase.append(node.get_val_loss_delta())
    values_val_loss.append(node.val_loss)
avg_increase = avg(values_increase)
avg_val_loss = avg(values_val_loss)
print('avg increase: %f' % avg_increase)
delta_ratio = 100.0 * avg_increase / avg_val_loss
print('avg increase fraction: %f' % delta_ratio)

file_increase_deltas = "increase-deltas-%s.data" % args.token
append(file_increase_deltas, "%i %5.1f" % (args.stage, delta_ratio))
