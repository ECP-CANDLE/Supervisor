# PLOT IO TIMES PY

import argparse
import os
import pickle
import statistics

from utils import fail

parser = argparse.ArgumentParser(description="Plot I/O stats")
parser.add_argument("directory", help="The experiment directory (EXPID)")

args = parser.parse_args()

node_pkl = args.directory + "/node-info.pkl"

try:
    with open(node_pkl, "rb") as fp:
        data = pickle.load(fp)
except IOError as e:
    fail(e, os.EX_IOERR, "Could not read: " + node_pkl)

builds = {1: [], 2: [], 3: [], 4: [], 5: []}
loads = {1: [], 2: [], 3: [], 4: [], 5: []}
writes = {1: [], 2: [], 3: [], 4: [], 5: []}

# Print the node info!
for node in data.values():
    if node.stage == 6:
        continue
    if node.build_df is not None:
        builds[node.stage].append(node.build_df)
    if node.load_initial is not None:
        loads[node.stage].append(node.load_initial)
    if node.ckpt_writes is not None:
        writes[node.stage] += list(node.ckpt_writes.values())

with open(args.directory + "/builds.data", "w") as fp:
    for stage in builds.keys():
        fp.write("%i  " % stage)
        fp.write("%0.3f" % statistics.mean(builds[stage]))
        fp.write("  # count = %i\n" % len(builds[stage]))

with open(args.directory + "/loads.data", "w") as fp:
    for stage in loads.keys():
        if stage == 1:
            continue  # stage 1 does not do a load
        fp.write("%i " % stage)
        fp.write("%0.3f\n" % statistics.mean(loads[stage]))

with open(args.directory + "/writes.data", "w") as fp:
    for stage in writes.keys():
        fp.write("%i " % stage)
        fp.write("%0.3f\n" % statistics.mean(writes[stage]))
