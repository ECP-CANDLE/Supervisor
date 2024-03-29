# MODEL RUNNER PY

# See __main__ section for usage

import importlib
import json
import math
import os
import sys
import time
import traceback
import importlib
import runner_utils
from log_tools import *
from runner_utils import ModelResult

logger = None

print("MODEL RUNNER MODULE")
sys.stdout.flush()

# Set PYTHONPATH:
# Let MODEL_PYTHON_DIR override default Benchmarks model locations
python_dir = os.getenv("MODEL_PYTHON_DIR")
if python_dir:
    sys.path.append(python_dir)

# This is for candle_lib, which is not in Benchmarks any more
# benchmarks_root = os.getenv("BENCHMARKS_ROOT")
# if benchmarks_root:
#     sys.path.append(benchmarks_root+'/common')

# Report PYTHONPATH for debugging
print("sys.path:")
for i in range(0, len(sys.path) - 1):
    print("%2i: %s" % (i, sys.path[i]))
print("")


def import_pkg(framework, model_name):
    """
    The model_name is the short form of the Benchmark: e.g., "nt3"
    The module_name is the name of the Python module:
        e.g., 'nt3_baseline_keras2'
    """
    log("model_name:  " + model_name)
    module_name = os.getenv("MODEL_PYTHON_SCRIPT")
    if framework == "keras":
        framework = framework + "2"
    elif framework == "pytorch":
        import torch  # noqa: F401
    else:
        raise ValueError("Framework must either be 'keras' or 'pytorch' " +
                         "got: '{}'".format(framework))

    if module_name is None or module_name == "":
        module_name = model_name + "_baseline_keras2"
    log("module_name: " + module_name)
    pkg = importlib.import_module(module_name)
    return pkg


def log(msg):
    global logger
    logger.info(msg)


def debug(msg):
    global logger
    logger.debug(msg)


def timestamp():
    from datetime import datetime

    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def setup_perf(params):
    return {"top": setup_perf_top(params), "nvidia": setup_perf_nvidia(params)}


def setup_perf_top(params):
    if "perf_top" not in params:
        return None
    if params["perf_top"] == "0":
        return None
    try:
        delay = int(params["perf_top"])
    except Exception:
        msg = ('setup_perf_top(): params[perf_top] not an int: got: "%s"' %
               params["perf_top"])
        print(msg)
        raise Exception(msg)
    import subprocess

    with open("perf-top.log", "a") as fp_out:
        fp_out.write("model_runner: start: %s\n\n" % timestamp())
        P = subprocess.Popen(["top", "-b", "-d", delay],
                             stdout=fp_out,
                             stderr=subprocess.STDOUT)
    return P


def setup_perf_nvidia(params):
    if "perf_nvidia" not in params:
        return None
    if params["perf_nvidia"] == "0":
        return None
    try:
        delay = int(params["perf_nvidia"])
    except Exception:
        msg = ("setup_perf_nvidia(): params[perf_nvidia] not an int: " +
               'got: "%s"' % params["perf_nvidia"])
        print(msg)
        raise Exception(msg)
    import subprocess

    with open("perf-nvidia.log", "a") as fp_out:
        fp_out.write("model_runner: start: %s\n\n" % timestamp())
        P = subprocess.Popen(["nvidia-smi", "--loop=%i" % delay],
                             stdout=fp_out,
                             stderr=subprocess.STDOUT)
    return P


def stop_perf(Ps):
    for s in ["top", "nvidia"]:
        if Ps[s] is not None:
            Ps[s].terminate()


def run(hyper_parameter_map, model_return):
    start = time.time()
    global logger
    logger = get_logger(logger, "MODEL RUNNER")

    logger.debug("run(): START:")

    directory = hyper_parameter_map[
        "instance_directory"]  # should be output_dir
    os.chdir(directory)

    with open(directory + "/rank.txt", "w") as fp:
        fp.write(str(os.getenv("ADLB_RANK_SELF")) + "\n")

    framework = hyper_parameter_map['framework']
    log("framework:   " + str(framework))
    model_name = hyper_parameter_map['model_name']
    pkg = import_pkg(framework, model_name)

    runner_utils.format_params(hyper_parameter_map)

    params_arg = {}
    if "CANDLE_DEFAULT_MODEL_FILE" in os.environ:
        config_file = os.getenv("CANDLE_DEFAULT_MODEL_FILE")
        logger.info('CANDLE_DEFAULT_MODEL_FILE: "%s"' % config_file)
        params_arg = {"default_model": config_file}
    if "config_file" in hyper_parameter_map:
        config_file = hyper_parameter_map["config_file"]
        logger.info('specified config_file: "%s"' % config_file)
        params_arg = {"default_model": config_file}

    # params is a Python dictionary
    params = setup_params(pkg, hyper_parameter_map, params_arg)

    Ps = setup_perf(params)

    history = None
    exception = False

    # check for epochs if not present set to 1,
    # used for checking early stopping in function get_results
    if "epochs" in hyper_parameter_map:
        epochs = hyper_parameter_map["epochs"]
    else:
        epochs = 1

    log("PKG RUN START")
    if framework == "keras":

        try:
            # Run the model!
            history = pkg.run(params)
        except Exception as e:
            logger.info("RUN EXCEPTION: " + str(e))
            print("RUN EXCEPTION: " + str(e))
            info = sys.exc_info()
            s = traceback.format_tb(info[2])
            # This produces backslashes in output like "\n\n"
            #      on Frontier 2023-02-26
            # sys.stdout.write('\\n\\nEXCEPTION in model run(): \\n' +
            #                  repr(e) + ' ... \\n' + ''.join(s))
            # sys.stdout.write('\\n')
            sys.stdout.write('\n\nEXCEPTION in model run(): \n' + repr(e) +
                             ' ... \n' + ''.join(s))
            sys.stdout.write('\n')
            sys.stdout.flush()
            exception = True
            exit(1)
        runner_utils.keras_clear_session(framework)

        # Default result if there is no val_loss (as in infer.py)
        result = 0
        history_result = {}
        if not exception:
            if history is not None:
                if history == "EPOCHS_COMPLETED_ALREADY":
                    result, history_result = "EPOCHS_COMPLETED_ALREADY", None
                else:
                    result, history_result = get_results(
                        history, model_return, epochs)
        else:
            result, history_result = "RUN_EXCEPTION", None

    elif framework == 'pytorch':
        val_scores, infer_scores = pkg.run(params)

        class history:

            def __init__(self, val_scores):
                self.history = {'val_loss': [val_scores['val_loss']]}

        history = history(val_scores)
        result, history_result = get_results(history, model_return, epochs)

    stop_perf(Ps)
    finish = time.time()
    duration = finish - start

    #  print the run_id and duration
    logger.info("DONE: run_id %s in %0.2f seconds." %
                (hyper_parameter_map["run_id"], duration))
    log("PKG RUN STOP")
    sys.stdout.flush()

    return (result, history_result)


def get_model_return():
    model_return = os.getenv("MODEL_RETURN")
    valid_model_returns = ["loss", "val_loss", "val_corr", "val_acc"]
    if model_return is None:
        raise Exception("No MODEL_RETURN was in the environment!")
    if model_return not in valid_model_returns:
        raise Exception("Invalid value for MODEL_RETURN: use: " +
                        str(valid_model_returns))
    return model_return


def load_pre_post(hyper_parameter_map, key):
    module = None
    if key in hyper_parameter_map:
        module_name = hyper_parameter_map[key]
        module = importlib.import_module(module_name)
    return module


def run_pre(hyper_parameter_map):
    module = load_pre_post(hyper_parameter_map, "pre_module")
    result = ModelResult.SUCCESS
    if module is not None:
        logger.debug("PRE RUN START")
        result = module.pre_run(hyper_parameter_map)
        logger.debug("PRE RUN STOP")
    return result


def run_post(hyper_parameter_map, output_map):
    module = load_pre_post(hyper_parameter_map, "post_module")
    if module is not None:
        logger.debug("POST RUN START")
        module.post_run(hyper_parameter_map, output_map)
        logger.debug("POST RUN STOP")


def run_model(hyper_parameter_map):
    # In-memory Python runs may not create sys.argv
    if "argv" not in dir(sys):
        # This is needed for CANDLE Benchmarks finalize_parameters():
        sys.argv = ["null"]
    instance_directory = hyper_parameter_map["instance_directory"]
    os.chdir(instance_directory)
    global logger
    logger = get_logger(logger, "MODEL RUNNER")
    model_return = get_model_return()
    # logger.info("run_model: node: " + hyper_parameter_map['node'])
    directory = hyper_parameter_map["instance_directory"]
    os.chdir(directory)
    if os.path.exists("stop.marker"):
        logger.info("stop.marker exists!")
        return ("SKIP", "STOP_MARKER")
    result = run_pre(hyper_parameter_map)
    if result == ModelResult.ERROR:
        logger.error("model_runner: run_pre() returned ERROR ...")
        logger.error("model_runner: EXIT CODE=1")
        sys.stdout.flush()
        # Allow time for other failures to finish writing:
        time.sleep(60)
        exit(1)
    elif result == ModelResult.SKIP:
        logger.info("model_runner: run_pre() returned SKIP ...")
        logger.info("model_runner: returning SKIP.")
        return ("SKIP", "HISTORY_EMPTY")
    else:
        assert result == ModelResult.SUCCESS  # proceed...

    result, history = run(hyper_parameter_map, model_return)
    runner_utils.write_output(result, directory)
    runner_utils.write_output(
        json.dumps(history, cls=runner_utils.FromNPEncoder), directory,
        "history.txt")
    run_post(hyper_parameter_map, {})
    logger.info("RUN STOP")
    return (result, history)


def setup_params(pkg, hyper_parameter_map, params_arg):
    params = pkg.initialize_parameters(**params_arg)
    logger.debug("PARAM UPDATE START")
    for k, v in hyper_parameter_map.items():
        if k == "dense" or k == "dense_feature_layers":
            if type(v) != list:
                v = v.split(" ")
            v = [int(i) for i in v]
        if k == "cell_features":
            cp_str = v
            v = list()
            v.append(cp_str)
        logger.debug(str(k) + " = " + str(v))
        params[k] = v
    logger.debug("PARAM UPDATE STOP")

    logger.debug("WRITE_PARAMS START")
    runner_utils.write_params(params, hyper_parameter_map)
    logger.debug("WRITE_PARAMS STOP")
    return params


def get_results(history, model_return, epochs_expected):
    """Return the history entry that the user requested via MODEL_RETURN, which
    may be math.nan in case of error.

    Also checks for early stopping and if so marks the directory
         with a 0-byte file named "stop.marker"
    history: The TensorFlow history
    """

    logger.debug('get_results(): "%s"' % model_return)

    known_params = ["loss", "val_loss"]

    if model_return not in known_params:
        raise ValueError("Unsupported objective function return " + 'key: "' +
                         model_return + '" - ' +
                         "use model_param to specify one of " +
                         str(known_params))

    if model_return in history.history:
        # Good value
        values = history.history[model_return]
        if len(values) < epochs_expected:
            msg = "early stopping: %i/%i" % (len(values), epochs_expected)
            logger.info("get_results(): " + msg)
            with open("stop.marker", "w") as fp:
                fp.write(msg + "\n")
        print("VALUES: ", values, values[-1], type(values[-1]))
        # Default: the last value in the history
        result = float(values[-1])
    else:
        logger.warning("get_results(): model return key " + "not found: " +
                       'key: "' + model_return + '" - ' + "history: " +
                       str(history.history.keys()))
        logger.warning("get_results(): returning NaN")
        result = math.nan

    print("result: " + model_return + ": " + str(result))
    print("IMPROVE_RESULT " + str(result))
    history_result = history.history.copy()
    return result, history_result


# Usage: see how sys.argv is unpacked below:
if __name__ == "__main__":
    logger = get_logger(logger, "MODEL_RUNNER")
    logger.info("main: RUN START")

    import sys

    (
        _,  # The Python program name (unused)
        param_string,
        instance_directory,
        framework,
        runid,
        benchmark_timeout,
    ) = sys.argv

    hyper_parameter_map = runner_utils.init(param_string,
                                            instance_directory,
                                            framework,
                                            out_dir_key="save")
    hyper_parameter_map["model_name"] = os.getenv("MODEL_NAME")
    if hyper_parameter_map["model_name"] is None:
        raise Exception("No MODEL_NAME was in the environment!")
    hyper_parameter_map["experiment_id"] = os.getenv("EXPID")
    hyper_parameter_map["run_id"] = runid
    hyper_parameter_map["timeout"] = float(benchmark_timeout)

    # tensorflow.__init__ calls _os.path.basename(_sys.argv[0])
    # so we need to create a synthetic argv.
    # if (not hasattr(sys, 'argv')) or (len(sys.argv) == 0):
    # sys.argv  = ['nt3_tc1']
    sys.argv = ["null"]
    run_model(hyper_parameter_map)
