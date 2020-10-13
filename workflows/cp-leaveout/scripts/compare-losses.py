
# COMPARE LOSSES PY

# Input:  Provide two experiment directories
# Output: Stream of NODE_ID LOSS1 LOSS2

import argparse, pickle

parser = argparse.ArgumentParser(description='Parse all log files')
parser.add_argument('directory1',
                    help='The 1st experiment directory (EXPID)')
parser.add_argument('directory2',
                    help='The 2nd experiment directory (EXPID)')

args = parser.parse_args()

# logging.basicConfig(level=logging.DEBUG, format="%(message)s")
# logger = logging.getLogger("extract_node_info")

node_pkl_1 = args.directory1 + "/node-info.pkl"
node_pkl_2 = args.directory2 + "/node-info.pkl"

with open(node_pkl_1, "rb") as fp:
    nodes_1 = pickle.load(fp)
with open(node_pkl_2, "rb") as fp:
    nodes_2 = pickle.load(fp)
# print("%i %i" % (len(nodes_1), len(nodes_2)))

count = 1
for node_id in nodes_2:
    loss_1 = nodes_1[node_id].val_loss
    loss_2 = nodes_2[node_id].val_loss
    print("%2i %s %8.7f %8.7f" % (count, node_id, loss_1, loss_2))
    count += 1
