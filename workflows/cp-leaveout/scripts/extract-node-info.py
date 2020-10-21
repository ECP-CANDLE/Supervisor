
# EXTRACT NODE INFO PY

# Input:  Provide an experiment directory
# Output: A pickle file in the experiment directory

# Use print-node-info to print the node info
# See Node.py for the data structure

import argparse, logging, os, pickle, sys
import pprint

from utils import fail
from Node import Node

parser = argparse.ArgumentParser(description='Parse all log files')
parser.add_argument('directory',
                    help='The experiment directory (EXPID)')

args = parser.parse_args()

log_list = args.directory + "/log-list.txt"
node_pkl = args.directory + "/node-info.pkl"

logging.basicConfig(level=logging.INFO, format="%(message)s")
logger = logging.getLogger("extract_node_info")

def read_log_filenames(log_list):
    result = []
    count = 0
    limit = 5000 # Reduce this for debugging
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
        fail(e, os.EX_IOERR, "Could not read: " + log_list)
    return result

def parse_logs(log_files):
    # Dict mapping Node id to Node for all complete Nodes
    nodes = {}
    logger.warning("Opening %i log files..." % len(log_files))
    try:
        total = len(log_files)
        index = 0
        for log_file in log_files:
            progress = "%4i/%4i (%2.f%%)" % \
                       (index, total, 100.0*index/total)
            logger.info("Opening: %12s %s" % (progress, log_file))
            with open(log_file) as fp:
                parse_log(fp, nodes)
            index += 1
    except IOError as e:
        fail(e, os.EX_IOERR, "Could not read: " + log_file)
    return nodes

def parse_log(log_fp, nodes):
    nodes_found = 0
    node_current = None
    while True:
        line = log_fp.readline()
        # print(line)
        if line == "": break
        if "PARAM UPDATE START" in line:
            trace("New Node ...")
            node_current = Node(logger=logger)
            node_current.parse_date_start(line)
        if "MODEL RUNNER DEBUG  node =" in line:
            tokens = line.split()
            node_id = tokens[-1].strip()
            node_current.set_id(node_id, logger)
        elif "MODEL RUNNER DEBUG  epochs =" in line:
            node_current.parse_epochs(line, logger)
        elif line.startswith("Epoch ") and "/" in line:
            node_current.parse_epoch_status(line, logger)
        elif Node.training_done in line:
             node_current.parse_training_done(line, logger)
        elif "early stopping" in line:
            if node_current != None:
                # TensorFlow may report early stopping even if at max epochs:
                node_current.stop_early()
        elif "DONE: run_id" in line:
            logger.debug("RUN DONE.")
            node_current.parse_date_stop(line, logger)
        if node_current != None and node_current.complete:
            # Store a complete Node in global dict nodes
            logger.debug("NODE DONE.")
            nodes[node_current.id] = node_current
            find_val_data(node_current)
            nodes_found += 1
            node_current = None

    logger.info("Found %i nodes in log." % nodes_found)

def trace(message):
    logger.log(level=logging.DEBUG-5, msg=message)

def find_val_data(node):
    python_log = args.directory + "/run/%s/save/python.log" % node.id
    if not os.path.exists(python_log):
        return
    with open(python_log) as fp:
        node.parse_val_data(fp)
    if node.val_data == None:
        logger.fatal("Could not find val data for node: " + node.id)

# List of log file names
log_files = read_log_filenames(log_list)
# Dict mapping Node id to Node for all complete Nodes
nodes = parse_logs(log_files)

logger.warning("Found %i nodes in total." % len(nodes))

with open(node_pkl, "wb") as fp:
    pickle.dump(nodes, fp)

logger.warning("Wrote pickle: %s ." % node_pkl)
