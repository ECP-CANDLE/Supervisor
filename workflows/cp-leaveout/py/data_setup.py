
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
        self.cell_feature_selection = None
        self.drug_feature_selection = None
        self.output = output

def pre_run(params):
    import sys, time
    print("data_setup.pre_run(): node: '%s' ..." % params["node"])
    sys.stdout.flush()

    # check NVMe disk is available
    username = os.environ['USER']
    nvme_enabled = Path('/mnt/bb/{}'.format(username)).exists()

    if nvme_enabled:
        # copy original datafrom to NVMe disk space
        try:
            src = Path(params["dataframe_from"])
            dest = Path("/mnt/bb/{}/{}".format(username, src.name))
            if not dest.exists():
                start = time.time()
                count = dest.write_bytes(src.read_bytes())
                stop = time.time()
                duration = stop - start
                rate = count / duration / (1024*1024)
                print("File copy completed. Original dataframe " +
                      "copied to NVM in %0.1f seconds (%0.1f MB/s)." %
                      (duration, rate))
            else:
                print("File copy skipped. Original dataframe already exists in NVM.")
        except Exception as e:
            print("Error occurred in copying original dataframe\n" + str(e))
            traceback.print_exc()
            return ModelResult.ERROR
        params["dataframe_from"] = dest.resolve()
        params["use_exported_data"] = "/mnt/bb/{}/{}".format(username, params["use_exported_data"])

    # softlink to cache & config file
    # build node specific training/validation dataset

    args = TopN_Args(params["dataframe_from"],
                     params["node"],
                     params["plan"],
                     params["use_exported_data"])

    data = params["benchmark_data"]
    try:
        for filename in [ "cache", "uno_auc_model.txt" ]:
            if not os.path.islink(filename):
                os.symlink(f"{data}/{filename}", filename)
    except Exception as e:
        print("data_setup: error making symlink: %s\n" % filename + str(e))
        return ModelResult.ERROR

    try:
        print("data_setup: build_dataframe() ...")
        start = time.time()
        topN_to_uno.build_dataframe(args)
        stop = time.time()
        duration = stop - start
        print("data_setup: build_dataframe() OK : " +
              "%0.1f seconds." % duration)
    except ValueError:
        print("data_setup: caught ValueError for node: '%s'" %
              params["node"]) # new 2019-12-02
        traceback.print_exc(file=sys.stdout)
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
