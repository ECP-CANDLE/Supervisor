
# COMPARE ERRORS PY

# Input:  Provide two experiment DIRECTORIES and OUTPUT file
# Output: NODE_ID EPOCHS1 ERROR1 EPOCHS2 ERROR2
#         where an ERROR is MSE MAE R2 CORR

# Could easily be updated to pull out only one error stat
# (see commented code)

import argparse, pickle

parser = argparse.ArgumentParser(description="Parse all log files")
parser.add_argument("directory1",
                    help="The 1st experiment directory (EXPID)")
parser.add_argument("directory2",
                    help="The 2nd experiment directory (EXPID)")
# parser.add_argument("error",
#                     help="The error type to compare")
parser.add_argument("output",
                    help="The output file")

args = parser.parse_args()

# logging.basicConfig(level=logging.DEBUG, format="%(message)s")
# logger = logging.getLogger("extract_node_info")

node_pkl_1 = args.directory1 + "/node-info.pkl"
node_pkl_2 = args.directory2 + "/node-info.pkl"

# known_errors = ["mse", "mae", "r2", "corr"]
# if args.error not in known_errors:
#     print("given error '%s' not in known errors: %s" %
#           (args.error, known_errors))
#     exit(1)

with open(node_pkl_1, "rb") as fp:
    nodes_1 = pickle.load(fp)
with open(node_pkl_2, "rb") as fp:
    nodes_2 = pickle.load(fp)
# print("%i %i" % (len(nodes_1), len(nodes_2)))

def get_errors(node):
    return "%f %f %f %f" % (node.mse, node.mae, node.r2, node.corr)

# for node_id in nodes_1:
#     print(node_id)
# exit(1)

missing = 0
count   = 0
with open(args.output, "w") as fp:
    for node_id in nodes_2:
        if node_id not in nodes_1:
            print("missing: " + node_id)
            missing += 1
            continue
        count += 1
        epochs_1 = nodes_1[node_id].get_epochs_cumul(nodes_1)
        errors_1 = get_errors(nodes_1[node_id])
        epochs_2 = nodes_2[node_id].get_epochs_cumul(nodes_2)
        errors_2 = get_errors(nodes_2[node_id])
        fp.write("%2i %s %3i %s %3i %s\n" % (count, node_id,
                                             epochs_1, errors_1,
                                             epochs_2, errors_2))

print("compared: %2i" % count)
print("missing:  %2i" % missing)
print("wrote:    %s"  % args.output)
