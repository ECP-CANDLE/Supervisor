
# DATA SETUP PY

import json

from runner_utils import ModelResult
import topN_to_uno

class TopN_Args:
    def __init__(self, dataframe_from, node, plan):
        self.dataframe_from = dataframe_from
        self.node = node
        self.plan = plan

def pre_run(params):
    print("data_setup.pre_run()...")
    args = TopN_Args(params["dataframe_from"],
                     params["node"],
                     params["plan"])
    print("topN build node: '%s' ..." % params["node"])
    try:
        topN_to_uno.build_dataframe(args)
    except Exception as e:
        print("error in build_dataframe!\n" + str(e))
        return ModelResult.ERROR
    print("data_setup.pre_run() done.")
    return ModelResult.SUCCESS

def post_run(params):
    print("post_run")
    return ModelResult.SUCCESS
