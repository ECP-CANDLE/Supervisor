#!/usr/bin/env python

# NODE TIMES PY
#

import argparse, json, pickle

import Node

parser = argparse.ArgumentParser()
parser.add_argument('dir', type=str,
                    help='The directory with the node-info.pkl')
args = parser.parse_args()

node_pkl = args.dir + "/" + "node-info.pkl"

try:
    with open(node_pkl, 'rb') as fp:
        D = pickle.load(fp)
except Exception as e:
    print("could not read PKL file: %s\n" % node_pkl + str(e))
    exit(1)

# Each a (time, value) record
#   value=1 means job start ; value=0 means job stop
events = []

import datetime

for node_id in D.keys():
    node = D[node_id]
    fmt = "%Y-%m-%d %H:%M:%S"
    start = datetime.datetime.strptime(node.date_start, fmt).timestamp()
    stop  = datetime.datetime.strptime(node.date_stop,  fmt).timestamp()
    events.append((start, 1))
    events.append((stop, -1))

events.sort()

node_times_data = args.dir + "/node-times.data"
load = 0

def scale(t):
    offset = 1594305000
    return (t - offset)/3600

with open(node_times_data, "w") as fp:
    if len(events) > 0:        
        for event in events:
            fp.write("%12.1f %i\n" % (scale(event[0]), load))
            load = load + event[1]
            fp.write("%12.1f %i\n" % (scale(event[0]), load))
