
# DATA SETUP PY

import json

import topN_to_uno

class TopN_Args:
    def __init__(self, dataframe_from, node, plan):
        self.dataframe_from = dataframe_from
        self.node = node
        self.plan = plan

def pre_run(params):
    print("pre_run")
    args = TopN_Args(params["dataframe_from"],
                     params["node"],
                     params["plan"])
    print("topN build node: '%s' ..." % params["node"])
    topN_to_uno.build_dataframe(args)

def post_run(params):
    print("post_run")
