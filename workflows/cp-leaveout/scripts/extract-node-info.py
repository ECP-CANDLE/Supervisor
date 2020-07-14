
# EXTRACT NODE INFO PY

# Input:  Provide an experiment directory
# Output: A pickle file in the experiment directory

# Use print-node-info to print the node info
# See Node.py for the data structure

import argparse, logging, os, pickle, sys

from utils import fail
from Node import Node

parser = argparse.ArgumentParser(description='Parse all log files')
parser.add_argument('directory',
                    help='The experiment directory (EXPID)')

args = parser.parse_args()

log_list = args.directory + "/log-list.txt"
node_pkl = args.directory + "/node-info.pkl"

logging.basicConfig(level=logging.WARN, format="%(message)s")

def read_log_filenames(log_list):
    result = []
    count = 0
    limit = 2000 # Reduce this for debugging
    try:
        with open(log_list) as fp:
            for line in fp.readlines():
                count += 1
                if count >= limit:
                    break
                if len(line) <= 1:
                    continue
                line = line.strip()
                result.append(line)
    except IOError as e:
        abort(e, os.EX_IOERR, "Could not read: " + log_list)
    return result

def parse_logs(log_files):
    # Dict mapping Node id to Node for all complete Nodes
    nodes = {}
    logging.warning("Opening %i log files..." % len(log_files))
    try:
        for log_file in log_files:
            logging.info("Opening: " + log_file)
            with open(log_file) as fp:
                parse_log(fp, nodes)
    except IOError as e:
        abort(e, os.EX_IOERR, "Could not read: " + log_file)
    return nodes

def parse_log(log_fp, nodes):
    nodes_found = 0
    node_current = None
    while True:
        line = log_fp.readline()
        if line == "": break
        if "PARAM UPDATE START" in line:
            node_current = Node()
            node_current.parse_date_start(line)
        if "MODEL RUNNER DEBUG node =" in line:
            tokens = line.split()
            node_id = tokens[-1].strip()
            node_current.set_id(node_id)
        elif "MODEL RUNNER DEBUG epochs =" in line:
            node_current.parse_epochs(line)
        elif line.startswith("Epoch ") and "/" in line:
            node_current.parse_epoch_status(line)
        elif Node.training_done in line:
             node_current.parse_training_done(line)
        elif "early stopping" in line:
            if node_current != None:
                # TensorFlow may report early stopping even if at max epochs:
                node_current.stop_early()
        elif "DONE: run_id" in line:
            node_current.parse_date_stop(line)
        if node_current != None and node_current.complete:
            # Store a complete Node in global dict nodes
            nodes[node_current.id] = node_current
            nodes_found += 1
            node_current = None

    logging.info("Found %i nodes in log." % nodes_found)

# List of log file names
log_files = read_log_filenames(log_list)
# Dict mapping Node id to Node for all complete Nodes
nodes = parse_logs(log_files)

logging.warning("Found %i nodes in total." % len(nodes))

with open(node_pkl, "wb") as fp:
    pickle.dump(nodes, fp)

logging.warning("Wrote %s ." % node_pkl)
