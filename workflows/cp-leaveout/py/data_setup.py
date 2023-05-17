# DATA SETUP PY

import datetime
import os
import sys
import time
import traceback
from pathlib import Path

import topN_to_uno
from runner_utils import ModelResult
from log_tools import *


logger = get_logger(logger, "DATA SETUP")

logger.info("LOAD:")
sys.stdout.flush()


class TopN_Args:

    def __init__(self, dataframe_from, node, plan, output):
        self.dataframe_from = dataframe_from
        self.node = node
        self.plan = plan
        self.fold = None
        self.incremental = "True"
        self.cell_feature_selection = None
        self.drug_feature_selection = None
        self.output = output


def setup_local_fs(params):
    global logger
    # username = os.environ['USER']  # No longer works on Summit 2021-10-13
    username = params["user"]
    userdir = Path("/mnt/bb/%s" % username)
    nvme_enabled = userdir.exists()
    logger.info("NVMe: %r" % nvme_enabled)
    if not nvme_enabled:
        return params
    # The training data directory for this workflow node:
    nodedir = userdir / params["node"]
    os.makedirs(nodedir, exist_ok=True)
    # copy original datafrom to NVMe
    try:
        src = Path(params["dataframe_from"])
        local_orig = userdir / src.name
        local_train = nodedir / Path("topN.uno.h5")
        dest = Path(local_orig)
        if not dest.exists():
            start = time.time()
            count = dest.write_bytes(src.read_bytes())
            stop = time.time()
            duration = stop - start
            rate = count / duration / (1024 * 1024)
            logger.info("Original dataframe copied to NVM in " +
                  "%0.1f seconds (%0.1f MB/s)." % (duration, rate))
        else:
            # Report file size:
            stats = os.stat(local_orig)
            logger.info("Original dataframe already exists in NVM: size=%i" %
                        stats.st_size)
    except Exception as e:
        print("Error occurred in copying original dataframe\n" + str(e))
        sys.stdout.flush()
        traceback.print_exc()
        sys.stdout.flush()
        return ModelResult.ERROR
    params["dataframe_from"] = dest.resolve()
    # WARNING: this changes the location of the training data:
    params["dataframe_from"] = local_orig
    params["use_exported_data"] = local_train
    params["plan"] = str(userdir / Path(params["plan"]).name)
    logger.info("Using plan file: " + params["plan"])
    return params


def pre_run(params):
    global logger

    logger.info("pre_run(): node: '%s' ..." % params["node"])

    # softlink to cache & config file
    # build node specific training/validation dataset

    params = setup_local_fs(params)

    args = TopN_Args(
        params["dataframe_from"],
        params["node"],
        params["plan"],
        output=params["use_exported_data"],
    )

    data = params["benchmark_data"]
    try:
        for filename in ["uno_auc_model.txt"]:  # "cache",
            if not os.path.islink(filename):
                src = f"{data}/{filename}"
                logger.info("data_setup: src:  (%s)" % src)
                logger.info("data_setup: dest: (%s)" % filename)
                os.symlink(src, filename)
    except Exception as e:
        print("data_setup: error making symlink:")
        print("data_setup: pwd: " + os.getcwd())
        print("data_setup: src:  (%s)" % src)
        print("data_setup: dest: (%s)" % filename)
        print(str(e))
        sys.stdout.flush()
        return ModelResult.ERROR

    try:
        logger.info("build_dataframe(output=%s) ..." % args.output)
        sys.stdout.flush()
        if not os.path.exists(args.output):
            out_orig = args.output
            args.output = Path(str(out_orig) + ".part")
            start = time.time()
            topN_to_uno.build_dataframe(args)
            stop = time.time()
            duration = stop - start
            logger.info("build_dataframe() OK : " +
                        "%0.1f seconds." % duration)
            # sys.stdout.flush()
            os.rename(args.output, out_orig)
            logger.info("rename() OK")
            # sys.stdout.flush()
            args.output = out_orig
        else:
            print("data_setup: dataframe exists: %s" %
                  os.path.realpath(args.output))
    except topN_to_uno.topN_NoDataException:
        print("data_setup: caught topN_NoDataException: SKIP " +
              "for node: '%s'" % params["node"])
        # sys.stdout.flush()
        directory = params["instance_directory"]
        with open(directory + "/NO-DATA.txt", "a") as fp:
            ts = datetime.datetime.now()
            iso = ts.isoformat(sep=" ", timespec="seconds")
            fp.write(iso + "\n")
        return ModelResult.SKIP
    except ValueError:
        print("data_setup: caught ValueError for node: '%s'" % params["node"])
        sys.stdout.flush()
        traceback.print_exc(file=sys.stdout)
        return ModelResult.ERROR
    except Exception as e:
        print("data_setup: error in build_dataframe!\n" + str(e))
        sys.stdout.flush()
        traceback.print_exc(file=sys.stdout)
        sys.stdout.flush()
        return ModelResult.ERROR
    logger.info("data_setup.pre_run() done.")
    # sys.stdout.flush()
    return ModelResult.SUCCESS


def post_run(params, output_dict):
    global logger
    # logger.info("post_run")
    # sys.stdout.flush()
    if "use_exported_data" in params:
        try:
            # os.remove(params["use_exported_data"])
            pass
        except OSError as e:
            print("Error: %s - %s." % (e.filename, e.strerror))
    else:
        # print("use_exported_data not in params")
        pass
    return ModelResult.SUCCESS
