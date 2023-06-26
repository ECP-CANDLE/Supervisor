import json
import os
import os.path
import sys
import configparser

from enum import Enum

import numpy as np

try:
    basestring
except NameError:
    basestring = str

DATA_TYPES = {
    type(np.float16): "f16",
    type(np.float32): "f32",
    type(np.float64): "f64"
}


class FromNPEncoder(json.JSONEncoder):

    def default(self, obj):
        if isinstance(obj, np.integer):
            return int(obj)
        elif isinstance(obj, np.floating):
            return float(obj)
        elif isinstance(obj, np.ndarray):
            return obj.tolist()
        else:
            return super(FromNPEncoder, self).default(obj)


def write_output(result, instance_directory, fname="result.txt"):
    with open("{}/{}".format(instance_directory, fname), "w") as f_out:
        f_out.write("{}\n".format(result))


def init(param_string, instance_directory, framework, out_dir_key):
    # with open(param_file) as f_in:
    #    hyper_parameter_map = json.load(f_in)
    hyper_parameter_map = json.loads(param_string.strip())

    if not os.path.exists(instance_directory):
        os.makedirs(instance_directory)

    hyper_parameter_map["framework"] = framework
    hyper_parameter_map[out_dir_key] = "{}/output".format(instance_directory)
    hyper_parameter_map["instance_directory"] = instance_directory

    return hyper_parameter_map


def is_numeric(val):
    try:
        float(val)
        return True
    except ValueError:
        return False


def format_params(hyper_parameter_map):
    for k, v in hyper_parameter_map.items():
        vals = str(v).split(" ")
        if len(vals) > 1 and is_numeric(vals[0]):
            # assume this should be a list
            if "." in vals[0]:
                hyper_parameter_map[k] = [float(x) for x in vals]
            else:
                hyper_parameter_map[k] = [int(x) for x in vals]


def write_params(params, hyper_parameter_map):
    parent_dir = (hyper_parameter_map["instance_directory"]
                  if "instance_directory" in hyper_parameter_map else ".")
    f = "{}/parameters.txt".format(parent_dir)
    montr = []  # Monitor params
    with open(f, "w") as f_out:
        f_out.write("[Global Params]\n")
        for k, v in params.items():
            if type(v) in DATA_TYPES:
                v = DATA_TYPES[type(v)]
            if isinstance(v, basestring):
                v = "'{}'".format(v)

            if k == "solr_root" or k == "timeout":
                # this must written at the end
                montr.append((k, v))
            else:
                f_out.write("{}={}\n".format(k, v))
        f_out.write("[Monitor Params]\n")
        for kv in montr:
            f_out.write("{}={}\n".format(*kv))


def expand_params(params, hyper_parameter_map):
    """Expand dict of params into command-line flags."""

    parent_dir = (hyper_parameter_map["instance_directory"]
                  if "instance_directory" in hyper_parameter_map else ".")
    result = ""
    for k, v in params.items():
        if type(v) in DATA_TYPES:
            v = DATA_TYPES[type(v)]
        if isinstance(v, basestring):
            v = "{}".format(v)
        if k == "model_name" and v.endswith(".sif"):
            # Replace with base filename without suffix:
            v = os.path.basename(v)[:-4]
        if k == "solr_root" or k == "timeout" or k == "id":
            pass  # Not a command-line parameter
        else:
            result += "--{} {} ".format(k, v)
    return result


def keras_clear_session(framework):
    if framework == "keras":
        # works around this error:
        # https://github.com/tensorflow/tensorflow/issues/3388
        try:
            from tensorflow.keras import backend as K
            K.clear_session()
        except AttributeError:  # theano does not have this function
            pass


class ModelResult(Enum):
    SUCCESS = 1
    SKIP = 2
    ERROR = 3


def read_config_file_dict(file: str) -> dict:
    result = {}
    config = configparser.ConfigParser()
    config.read(file)

    for section in config.sections():
        for k, v in config.items(section):
            result[k] = eval(v)
    return result


def merge_params(defaults, params):
    result = defaults.copy()
    for k, v in params.items():
        print("merge_params(): set " + str(k) + ' = ' + str(v))
        result[k] = v
    return result


def main():
    # Need argparse
    if sys.argv[1] == "write_params":
        # Merge params from the user-provided params file and
        # the workflow-generated parameters
        # Parse the workflow-provided JSON string:
        J = json.loads(sys.argv[2])
        # Assume we are in the correct directory for this file:
        defaults = read_config_file_dict(sys.argv[3])
        params = merge_params(defaults, J)
        print("params: " + str(params))
        write_params(params, {})
    elif sys.argv[1] == "expand_params":
        # Merge params from the user-provided params file and
        # the workflow-generated parameters and create
        # a set of command line flags to pass to CANDLE parser_utils
        if not (len(sys.argv) == 3 or len(sys.argv) == 4):
            print("runner_utils: bad subcommand args: " + str(sys.argv))
            exit(1)
        # Parse the workflow-provided JSON string:
        params = json.loads(sys.argv[2])
        if len(sys.argv) == 3:
            pass  # No defaults, OK
        elif len(sys.argv) == 4:
            defaults = read_config_file_dict(sys.argv[3])
            params = merge_params(defaults, params)
        params = expand_params(params, {})
        print(params)
    else:
        print("runner_utils: unknown subcommand: " + str(sys.argv))
        exit(1)


if __name__ == "__main__":
    main()
