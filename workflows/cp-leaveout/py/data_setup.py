
# DATA SETUP PY

import json
import os

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
    data = params["benchmark_data"]
    try:
        for filename in [ "cache", "uno_auc_model.txt" ]:
            if not os.path.islink(filename):
                os.symlink(f"{data}/{filename}", filename)
    except Exception as e:
        print("data_setup: error making symlink: %s\n" % filename + str(e))
        return ModelResult.ERROR
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
