# PRINT NODE INFO PY

import argparse
import os
import pickle
import sys

from Node import Node
from utils import fail

parser = argparse.ArgumentParser(description="Print Node info stats")
parser.add_argument("--count",
                    "-c",
                    action="store_true",
                    help="Simply count the nodes")
parser.add_argument("directory", help="The experiment directory (EXPID)")
parser.add_argument("nodes",
                    default="",
                    nargs="*",
                    help="Nodes to print (optional, defaults to all)")

args = parser.parse_args()

node_pkl = args.directory + "/node-info.pkl"

try:
    with open(node_pkl, "rb") as fp:
        data = pickle.load(fp)
except IOError as e:
    fail(e, os.EX_IOERR, "Could not read: " + node_pkl)

# Raw data printing:
# print(str(args))
# print(len(data))
# print(data)


def print_all(data):
    # Print the node info!
    print("print_all")
    count = 0
    earlies = 0
    for node in data.values():
        # print(node.id)
        print(node.str_table())
        count += 1
        if node.stopped_early:
            earlies += 1
    print("print-node-info: %i/%i runs stopped early." % (earlies, count))


def print_selected(data, nodes):
    for node_id in nodes:
        try:
            node = data[node_id]
        except KeyError:
            print("Could not find node: '%s'" % node_id)
            exit(1)
        print(node.str_table())


if args.count:
    print(len(data))
    exit(0)

if args.nodes == "":
    print_all(data)
else:
    print_selected(data, args.nodes)
