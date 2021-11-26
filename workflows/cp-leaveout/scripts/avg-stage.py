
# AVG STAGE PY

import argparse, os, pickle, statistics

from utils import fail

STAGE_ANY = 0

parser = argparse.ArgumentParser(description="Finds loss increases.")
parser.add_argument("directory",
                    help="The experiment directory (EXPID)")
parser.add_argument("--filename", "-f",
                    default="node-info",
                    help="Change the node pkl file name")
args = parser.parse_args()


node_pkl = args.directory + "/" + args.filename + ".pkl"

try:
    with open(node_pkl, "rb") as fp:
        # This is a dict ("node_id" -> Node)
        data = pickle.load(fp)
except IOError as e:
    fail(e, os.EX_IOERR, "Could not read: " + node_pkl)

print("total nodes: %i" % len(data))

# Total Node count:
total = 0
# stages = { 1:[], 2:[], 3:[], 4:[], 5:[] }
# epochs = { 1:[], 2:[], 3:[], 4:[], 5:[] }
times  =  { 1:[], 2:[], 3:[], 4:[], 5:[] }
vlosses = { 1:[], 2:[], 3:[], 4:[], 5:[] }

for node_id in data.keys():
    node = data[node_id]
    if not node.complete:
        continue
    # stages[node.stage].append(node.time)
    # epochs[node.stage].append(node.epochs_actual)
    times[node.stage].append(node.get_segments()/node.epochs_actual)
    vlosses[node.stage].append(node.val_loss)
    if node.stage == 3:
        print("%s %0.2f %i" % (node.id,
                                     node.get_segments(),
                                     node.epochs_actual))

with open(args.directory + "/times.data", "w") as fp:
    for stage in times.keys():
        count = len(times[stage])
        # print("stage: %i (%i) %r" % (stage, count, times[stage]))
        timer = statistics.mean(times[stage])
        fp.write("%i %0.2f  # count=%i\n" % (stage, timer, count))

with open(args.directory + "/vlosses.data", "w") as fp:
    for stage in times.keys():
        count = len(times[stage])
        vloss = statistics.mean(vlosses[stage])
        fp.write("%i %0.6f  # count=%i\n" % (stage, vloss, count))
