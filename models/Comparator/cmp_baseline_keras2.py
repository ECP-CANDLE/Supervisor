
"""
CMP BASELINE KERAS2

Compares two models
"""

import json
import os
import subprocess
from pathlib import Path
from pprint import pprint as pp


import candle


class Comparator(candle.Benchmark):
    pass


file_path = os.path.dirname(os.path.realpath(__file__))


def initialize_parameters(default_model="cmp_default_model.txt"):
    global file_path
    bmk = Comparator(file_path,
                     default_model,
                     "keras",
                     prog="cmp_baseline",
                     desc="Meta-model to compare two models")
    # Initialize parameters
    gParameters = candle.finalize_parameters(bmk)
    print("CMP output_dir: " + gParameters["output_dir"])
    return gParameters


def run(gParameters):
    print("Comparator: START")
    pp(gParameters)
    global file_path
    print("file_path: %s" % file_path)

    supervisor = Path(file_path).absolute().parent.parent
    workflows = supervisor / "workflows"

    expid     = gParameters["experiment_id"]
    cmp_runid = gParameters["run_id"]

    gParams = partition_params(gParameters)

    results = [None, None]
    for i in [0, 1]:
        print("cmp: subjob: %i: START" % i)
        gParams[i]["output_dir"] = "/candle_data_dir"
        print("output_dir: " + gParams[i]["output_dir"])

        model_name = gParams[i]["model_name"]
        run_id = (cmp_runid + "-M%i" % i)
        gParams[i]["run_id"] = run_id
        run_dir = Path(os.getenv("CANDLE_DATA_DIR")) \
            / "cmp" / "Output" / expid / run_id

        print("run_dir: " + str(run_dir))
        os.makedirs(run_dir, exist_ok=True)
        os.chdir(run_dir)

        cmd = make_cmd(str(workflows), gParams[i])
        result_file = run_dir / ("result-%i.txt" % i)
        env = make_env(str(workflows), gParams[i], str(result_file))
        print("cmd:", cmd)
        print("env:", env)

        cmp_log_name = str(run_dir) + "/cmp-%i.log" % i
        with open(cmp_log_name, "w") as cmp_log:
            try:
                subprocess.run(cmd,
                               env=env,
                               stdout=cmp_log,
                               stderr=subprocess.STDOUT,
                               check=True)
            except subprocess.CalledProcessError:
                print("cmd failed.  See " + cmp_log_name)
                exit(1)
        with open(result_file) as fp:
            line = fp.readline()
            results[i] = float(line)
        print("cmp: result %i: %f" % (i, results[i]))
        print("cmp: subjob: %i: DONE" % i)
    diff = -abs(results[1] - results[0])
    print("cmp: result diff: %f" % diff)
    print("IMPROVE_RESULT %f" % diff)
    # with open(gParameters["output_dir"] + "/result.txt", "w") as fp:
    #     fp.write("%f\n" % diff)

    print("Comparator DONE.")


# Keys that break Uno:
discards = [
    # This is of type <type> - cannot make JSON:
    "data_type",
    # The following are unknown to Uno:
    "data_dir",
    "save",
    "instance_directory",
    "framework"
]


def partition_params(gParameters):
    """
    Convert keys like "cmp_*" and "cmp_[01]_*" to per-model keys
    cmp_* allows you to separate the cmp params from the underlying model params
    cmp_[01]_* allows you to provide different param values for models 0 and 1.
    return pair of dicts, each a gParams, that
    """

    global discards

    # These are the prefixes we need to find and remove:
    n0 = len("cmp_")
    nx = len("cmp_X_")

    # The cmp_ keys override the other keys,
    # so we have to hold them and assign them last:
    result   = ({}, {})
    override = ({}, {})

    for key in gParameters.keys():
        found = False
        for i in [0, 1]:
            if key.startswith("cmp_%i_" % i):
                k = key[nx:]
                # print("key 2: " + key + " " + k)
                override[i][k] = gParameters[key]
                # print(str(type(gParameters[key])))
                found = True
                break
        if found: continue
        if key.startswith("cmp_"):
            k = key[n0:]
            print("key: cmp_ : " + key + " " + k)
            assign_both(override, gParameters, key, k)
            continue

        # Discarded keys:
        if key in discards:
            # Do not propagate this key to models:
            continue

        # Else: plain gParam: assign to both outputs:
        # print("key: " + key)
        assign_both(result, gParameters, key)

    # Apply the overrides:
    for i in [0, 1]:
        result[i].update(override[i])

    print("")
    print("params 0:")
    pp(sorted(result[0]))

    print("")
    print("params 1:")
    pp(sorted(result[1]))
    print("")
    return result


def assign_both(result, gParameters, key, k=None):
    """ Assign to both underlying models 0 and 1. """
    if k is None: k = key
    for j in [0, 1]:
        result[j][k] = gParameters[key]
    # print(str(type(gParameters[key])))
    # print("assign: " + key)


def make_cmd(workflows, gParams):
    model_sh = workflows + "/common" + "/sh" + "/model.sh"
    cmd = [
        "bash",
        model_sh,
        "keras2",
        json.dumps(gParams),
        gParams["experiment_id"],
        gParams["run_id"],
        "SINGULARITY",
        gParams["model_name"],
        "train"
    ]
    return cmd


def make_env(workflows, gParams, result_file):
    env = {
        "WORKFLOWS_ROOT": workflows,
        "TURBINE_OUTPUT": gParams["output_dir"],
        "EXPID": gParams["experiment_id"],
        "SITE": "lambda",
        "BENCHMARK_TIMEOUT": "120",
        "MODEL_NAME": gParams["model_name"],
        "MODEL_RETURN": "loss",
        "CANDLE_MODEL_TYPE": "SINGULARITY",
        "CANDLE_DATA_DIR": os.getenv("CANDLE_DATA_DIR"),
        "ADLB_RANK_OFFSET": "0",
        "RESULT_FILE": result_file
    }
    return env


def main():
    gParameters = initialize_parameters()
    run(gParameters)


if __name__ == "__main__":
    main()
