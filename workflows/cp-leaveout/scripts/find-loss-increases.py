
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

print("total nodes: %i" % len(data))

# Artificial nodes for comparison:
# !! Updated upstream
node_loss_worst = Node("WORST")
node_loss_worst.loss = 0
node_loss_best  = Node("BEST")
node_loss_best.loss = 1000

# List of Nodes where loss increased:
increases_loss = []
# Total Node count:
total = 0
# Stage 5 Nodes
leaves = 0
for node_id in data.keys():
    # print("node: " + node_id)
    parent_id = node_id[0:-2] # '1.2.3' -> '1.2'
    if len(parent_id) == 1: # stage=1
        continue
    if parent_id not in data:
        print("parent not found.")
        continue
    current = data[node_id]
    parent  = data[parent_id]
    if current.stage == 5: leaves += 1
    if not (args.stage == STAGE_ANY or args.stage == current.stage):
        continue
    current.loss_delta = current.loss - parent.loss
    if current.loss_delta > 0:
        increases_loss.append(current)
    if current.val_loss > node_loss_worst.loss: node_worst = current
    if current.val_loss < node_loss_best.loss:  node_best  = current
    total += 1

fraction = 100.0 * len(increases_loss) / total
print('increases_loss/total = %i / %i (%02.f%%)' % \
      (len(increases_loss), total, fraction))

# Artificial nodes for comparison:
node_vl_worst = Node("WORST")
node_vl_worst.val_loss = 0
node_vl_best  = Node("BEST")
node_vl_best.val_loss = 1000
# ==
# val_loss:
node_worst_val_loss = Node("WORST VAL_LOSS")
node_worst_val_loss.val_loss = 0
node_best_val_loss  = Node("BEST VAL_LOSS")
node_best_val_loss.val_loss = 1000
# loss:
node_worst_loss = Node("WORST LOSS")
node_worst_loss.loss = 0
node_best_loss  = Node("BEST LOSS")
node_best_loss.loss = 1000
# !! Stashed changes

if args.stage != STAGE_ANY:
    print("STAGE: %i" % args.stage)

# !! Updated upstream
leaves = 0 # stage 5 Nodes

# List of Nodes where val_loss increased:
increases_vl = []
# Total Node count:
total = 0
for node_id in data.keys():
    # print("node: " + node_id)
    parent_id = node_id[0:-2] # '1.2.3' -> '1.2'
    if len(parent_id) == 1: # stage=1
        continue
    if parent_id not in data:
        print("parent not found.")
        continue
    current = data[node_id]
    parent  = data[parent_id]
    if current.stage == 5: leaves += 1
    if not (args.stage == STAGE_ANY or args.stage == current.stage):
        continue
    current.val_loss_delta = current.val_loss - parent.val_loss
    if current.val_loss_delta > 0:
        increases_vl.append(current)
    if current.val_loss > node_vl_worst.val_loss: node_worst = current
    if current.val_loss < node_vl_best.val_loss:  node_best  = current
    total += 1
# ==
def get_increases():
    # List of Nodes where loss increased:
    global increases_loss
    increases_loss = []
    # List of Nodes where val_loss increased:
    global increases_val_loss
    increases_val_loss = []

    global node_worst_loss, node_worst_val_loss
    global node_best_loss,  node_best_val_loss

    # count of Nodes:
    total = 0
    # count of stage 5 Nodes
    leaves = 0
    # count of Nodes with missing parent
    parents_missing = 0
    for node_id in data.keys():
        # print("node: " + node_id)
        parent_id = node_id[0:-2] # '1.2.3' -> '1.2'
        if len(parent_id) == 1: # stage=1
            continue
        if parent_id not in data:
            # print("parent not found.")
            parents_missing += 1
            continue
        current = data[node_id]
        parent  = data[parent_id]
        if current.stage == 5: leaves += 1
        if not (args.stage == STAGE_ANY or args.stage == current.stage):
            continue
        current.val_loss_delta = current.val_loss - parent.val_loss
        current.loss_delta = current.loss - parent.loss
        # Register increases:
        if current.val_loss_delta > 0:
            increases_val_loss.append(current)
        if current.loss_delta > 0:
            increases_loss.append(current)
        # Update best/worst:
        if current.loss     > node_worst_loss.loss:
            node_worst_loss = current
        if current.loss     < node_best_loss.loss:
            node_best_loss  = current
        if current.val_loss > node_worst_val_loss.val_loss:
            node_worst_val_loss = current
        if current.val_loss < node_best_val_loss.val_loss:
            node_best_val_loss  = current
        total += 1
    print("parents_missing: %i" % parents_missing)
    return total, leaves

# total:  count of Nodes
# leaves: count of stage 5 Nodes
total, leaves = get_increases()
# !! Stashed changes

print("leaves: %i" % leaves)

if total == 0: fail('No matching Nodes found!')

# !! Updated upstream
fraction = 100.0 * len(increases_vl) / total
print('increases_vl/total = %i / %i (%02.f%%)' % \
      (len(increases_vl), total, fraction))

file_increases_vl = "increases-vl-%s.data" % args.token
append(file_increases_vl, "%i %5.1f" % (args.stage, fraction))
# ==
fraction = 100.0 * len(increases_loss) / total
print('increases_loss/total = %i / %i (%02.f%%)' % \
      (len(increases_loss), total, fraction))
filename = "increases-loss-%s.data" % args.token
append(filename, "%i %5.1f" % (args.stage, fraction))

fraction = 100.0 * len(increases_val_loss) / total
print('increases_val_loss/total = %i / %i (%02.f%%)' % \
      (len(increases_val_loss), total, fraction))
filename = "increases-val_loss-%s.data" % args.token
append(filename, "%i %5.1f" % (args.stage, fraction))
# !! Stashed changes

print('worst loss:     ' + str(node_worst_loss))
print('best  loss:     ' + str(node_best_loss))
print('worst val_loss: ' + str(node_worst_val_loss))
print('best  val_loss: ' + str(node_best_val_loss))

exit()

print('DELTAS:')

increases_loss    .sort(key=Node.get_loss_delta)
increases_val_loss.sort(key=Node.get_val_loss_delta)
# stopped_early = 0
# for i in increases:
#     # print('%f %-14s %r' % (i.val_loss_delta, i.id, i.stopped_early))
#     if i.stopped_early: stopped_early += 1

def print_delta(prefix, node):
    print(prefix, str(node), 'delta: %f' % node.val_loss_delta)

# worst = increases[-1]
# print_delta('worst:    ', worst)

# n_01p = int(round(len(increases) / 100)) # Worst 1 percentile
# if n_01p == 0: n_01p = 1
# worst_01p = increases[-n_01p]
# print_delta('worst  1%:', worst_01p)

# n_10p = int(round(len(increases) / 10)) # Worst 10 percentile
# if n_10p == 0: n_10p = 1
# worst_10p = increases[-n_10p]
# print_delta('worst 10%:', worst_10p)

# print('increases that stopped early: %i' % stopped_early)

# values_increase = []
# values_val_loss = []

# for node in increases:
#     values_increase.append(node.get_val_loss_delta())
#     values_val_loss.append(node.val_loss)

# avg_increase = avg(values_increase)
# avg_val_loss = avg(values_val_loss)
# print('avg increase: %f' % avg_increase)
# delta_ratio = 100.0 * avg_increase / avg_val_loss
# print('avg increase fraction: %f' % delta_ratio)

# file_increase_deltas = "increase-deltas-%s.data" % args.token
# append(file_increase_deltas, "%i %5.1f" % (args.stage, delta_ratio))

# outliers_file = "outliers-%s.data" % args.token
# print("avg_increase", str(avg_increase))
# print("avg_val_loss", str(avg_val_loss))

def report_top_loss_deltas():
    print("%-2s %-12s %-8s %-8s %-8s %-8s" % \
          ("", "node", "loss", "parent", "delta", "ratio"))
    increases_loss.sort(key=Node.get_loss_delta, reverse=True)
    ratios = []
    index = 1
    for node in increases_loss:
        parent = data[node.parent()]
        ratio = node.get_loss_delta() / parent.loss
        print("%2i %-12s %0.6f %0.6f %0.6f %0.6f" %
              (index, node.id, node.loss, parent.loss,
               node.get_loss_delta(), ratio))
        ratios.append(ratio)
        index += 1
    ratios.sort()

def report_top_val_loss_deltas(increases_val_loss):
    print("%-2s %-12s %-8s %-8s %-8s %-8s %-8s" % \
          ("", "node", "val_loss", "parent", "delta", "ratio", "val_data"))
    increases_val_loss.sort(key=Node.get_val_loss_delta, reverse=True)
    ratios = []
    index = 1
    for node in increases_val_loss:
        parent = data[node.parent()]
        ratio = node.get_val_loss_delta() / parent.loss
        print("%2i %-12s %0.6f %0.6f %0.6f %0.6f %8i" %
              (index, node.id, node.val_loss, parent.val_loss,
               node.get_val_loss_delta(), ratio, node.val_data))
        ratios.append(ratio)
        index += 1
    ratios.sort()

report_top_val_loss_deltas(increases_val_loss)

# with open(outliers_file, "w") as fp:
#     i = 0
#     for ratio in ratios:
#         fp.write("%4i %0.7f\n" % (i, ratio))
#         i += 1

# with open(outliers_file, "w") as fp:
#     i = 0
#     for ratio in ratios:
#         fp.write("%4i %0.7f\n" % (i, ratio))
#         i += 1
