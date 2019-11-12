
# DATA SETUP PY

import json
import os

from pathlib import Path
import traceback
from runner_utils import ModelResult
import topN_to_uno

class TopN_Args:
    def __init__(self, dataframe_from, node, plan, output):
        self.dataframe_from = dataframe_from
        self.node = node
        self.plan = plan
        self.fold = None
        self.incremental = 'True'
        self.output = output 

def pre_run(params):
    print("data_setup.pre_run()...")

    # check NVMe disk is available
    username = os.environ['USER']
    nvme_enabled = Path('/mnt/bb/{}'.format(username)).exists()

    if nvme_enabled:
        # copy original datafrom to NVMe disk space
        try:
            src = Path(params["dataframe_from"])
            dest = Path("/mnt/bb/{}/{}".format(username, src.name))
            if not dest.exists():
                dest.write_bytes(src.read_bytes())
                print("File copy completed. Original dataframe copied to NVMe disk.\n")
            else:
                print("File copy skipped. Original dataframe already exists.\n")
        except Exception as e:
            print("Error occurred in copying original dataframe\n" + str(e))
            traceback.print_exc()
            return ModelResult.ERROR
        params["dataframe_from"] = dest.resolve()
        params["use_exported_data"] = "/mnt/bb/{}/{}".format(username, params["use_exported_data"])

    # softlink to cache & config file
    # build node specific training/validatoin dataset
    args = TopN_Args(params["dataframe_from"],
                     params["node"],
                     params["plan"],
                     params["use_exported_data"])

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
    except ValueError:
        return ModelResult.SKIP
    except Exception as e:
        print("data_setup: error in build_dataframe!\n" + str(e))
        traceback.print_exc()
        return ModelResult.ERROR
    print("data_setup.pre_run() done.")
    return ModelResult.SUCCESS

def post_run(params, output_dict):
    print("post_run")
    return ModelResult.SUCCESS
