# EXTRACT NODE INFO PY

# Input:  Provide an experiment directory
# Output: A pickle file in the experiment directory

# Use print-node-info to print the node info
# See Node.py for the data structure

import argparse
import logging
import os
import pickle

from Node import Node
from utils import fail

parser = argparse.ArgumentParser(description="Parse all log files")
parser.add_argument("directory", help="The experiment directory (EXPID)")

args = parser.parse_args()

log_list = args.directory + "/log-list.txt"
node_pkl = args.directory + "/node-info.pkl"

logging.basicConfig(level=logging.INFO, format="%(message)s")
logger = logging.getLogger("extract_node_info")


def read_log_filenames(log_list):
    result = []
    count = 0
    limit = 5000  # Reduce this for debugging
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
    # Dict mapping Node id to Node for all complete Nodes:
    nodes = {}
    logger.warning("Opening %i files..." % len(log_files))
    try:
        total = len(log_files)
        index = 0
        for log_file in log_files:
            progress = "%4i/%4i (%2.f%%)" % (index, total,
                                             100.0 * index / total)
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
    build_df = None

    while True:
        line = log_fp.readline()
        # print(line)
        if line == "":
            break
        if line.startswith("data_setup.pre_run"):
            if "node:" in line:
                tokens = line.split()
                node_id = tokens[-2].strip()
                node_current = get_node(nodes, node_id, logger)
        elif "DONE: run_id" in line:
            # This is also a MODEL RUNNER line,
            # but could be DEBUG or INFO
            # (should be INFO in future)
            if node_current is None:
                # Restarted node with no epochs remaining:
                continue
            trace("RUN DONE.")
            node_current.parse_date_stop(line, logger)
        elif "MODEL RUNNER" in line:
            # print(line.strip())
            if "PARAM UPDATE START" in line:
                node_current.parse_date_start(line)
            if " epochs =" in line:
                if node_current is None:
                    # Restarted node with no epochs remaining:
                    continue
                node_current.parse_epochs(line, logger)
        elif line.startswith("data_setup: build_dataframe() OK"):
            build_df = parse_build_df(line, logger)
        elif line.startswith("Loaded from initial_weights"):
            node_current.parse_load_initial(line, logger)
        elif line.startswith("Epoch ") and "/" in line:
            node_current.parse_epoch_status(line, logger)
        elif line.startswith("Current "):
            node_current.parse_current_time(line, logger)
        elif Node.training_done in line and "ETA:" not in line:
            node_current.parse_training_done(line, logger)
        elif line.startswith("model wrote:"):
            node_current.parse_model_write(line, logger)
        elif "topN_NoDataException" in line:
            node_current.has_data = False
        elif "early stopping" in line:
            if not "setting early stopping patience" in line:
                if node_current is not None:
                    # TensorFlow may report early stopping even if at max epochs:
                    node_current.stop_early()
        if node_current is not None and node_current.complete:
            # Store a complete Node in global dict nodes
            trace("node done.")
            # find_val_data(node_current) # old format?
            parse_python_log(node_current)
            # print(Node.str_table(node_current))
            nodes_found += 1
            node_current = None
            # exit(0)

    logger.info("Found %i nodes in log." % nodes_found)


def get_node(nodes, node_id, logger):

    if "'" in node_id:
        node_id = node_id.replace("'", "")
    if node_id not in nodes:
        trace("NEW:  " + node_id)
        result = Node(logger=logger)
        result.set_id(node_id, logger)
        nodes[node_id] = result
    else:
        trace("lookup: " + node_id)
        result = nodes[node_id]
        result.new_segment()
        result.complete = False
    return result


def parse_build_df(line, logger=None):
    tokens = line.split()
    assert len(tokens) == 6
    global build_df
    build_df = float(tokens[4])
    # logger.info("build_df: %0.2f" % build_df)
    return build_df


def trace(message):
    logger.log(level=logging.DEBUG - 5, msg=message)


# def find_val_data(node):
#     python_log = args.directory + "/run/%s/save/python.log" % node.id
#     if not os.path.exists(python_log):
#         return
#     with open(python_log) as fp:
#         node.parse_val_data(fp)
#     if node.val_data == None:
#         logger.fatal("Could not find val data for node: " + node.id)


def parse_python_log(node):
    python_log = args.directory + "/run/%s/save/python.log" % node.id
    if not os.path.exists(python_log):
        return
    with open(python_log) as fp:
        node.parse_python_log(fp)
    if node.mse is None:
        logger.fatal("Could not find error data for node: " + node.id)


# List of log file names
log_files = read_log_filenames(log_list)
# Dict mapping Node id to Node for all complete Nodes
nodes = parse_logs(log_files)

logger.warning("Found %i nodes in total." % len(nodes))

with open(node_pkl, "wb") as fp:
    pickle.dump(nodes, fp)

logger.warning("Wrote pickle: %s ." % node_pkl)
