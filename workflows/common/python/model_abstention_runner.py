
# MODEL RUNNER PY

# See __main__ section for usage

import sys
import json
import os
import time
import numpy as np
import importlib
import runner_utils
from runner_utils import ModelResult
import log_tools
import math

logger = None

print("MODEL RUNNER...")

# Andrew: Adding the following line (switching the order of the following two lines) in order to append an arbitrary model's dependencies to the path *before* the benchmarks in order to accidentally use a benchmark dependency
# append ${MODEL_PYTHON_DIR} to $PATH if variable is set
python_dir = os.getenv("MODEL_PYTHON_DIR")
if python_dir:
    sys.path.append(python_dir)
# append ${BENCHMARKS_ROOT}/common to $PATH if variable is set
benchmarks_root = os.getenv("BENCHMARKS_ROOT")
if benchmarks_root:
    sys.path.append(benchmarks_root+"/common")

# import candle_lrn_crv

print("sys.path:")
for i in range(0, len(sys.path)-1):
    print("%2i: %s" % (i, sys.path[i]))
print("")

def import_pkg(framework, model_name):
    # The model_name is the short form of the Benchmark: e.g., 'nt3'
    # The module_name is the name of the Python module:  e.g., 'nt3_baseline_keras2'
    print("model_name: ", model_name)
    module_name = os.getenv("MODEL_PYTHON_SCRIPT")
    if framework == 'keras':
        if module_name == None or module_name == "":
            module_name = "{}_abstention_keras2".format(model_name)
        print ("module_name:", module_name)
        pkg = importlib.import_module(module_name)
    elif framework == 'pytorch':
        import torch
        if module_name == None or module_name == "":
            module_name = "{}_baseline_pytorch".format(model_name)
            print ("module_name:", module_name)
        pkg = importlib.import_module(module_name)
    else:
        raise ValueError("Framework must either be `keras' or `pytorch' " +
                         "got `{}'!".format(framework))

    return pkg


def log(msg):
    global logger
    logger.debug(msg)

def timestamp():
    from datetime import datetime
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def setup_perf(params):
    return { 'top':    setup_perf_top(params),
             'nvidia': setup_perf_nvidia(params) }


def setup_perf_top(params):
    if 'perf_top' not in params:
        return None
    if params['perf_top'] == '0':
        return None
    try:
        delay = int(params['perf_top'])
    except:
        msg = 'setup_perf_top(): params[perf_top] not an int: got: "%s"' % \
              params['perf_top']
        print(msg)
        raise Exception(msg)
    import subprocess
    with open('perf-top.log', 'a') as fp_out:
        fp_out.write('model_runner: start: %s\n\n' % timestamp())
        P = subprocess.Popen(['top', '-b', '-d', params['perf_top']],
                             stdout=fp_out,
                             stderr=subprocess.STDOUT)
    return P

def setup_perf_nvidia(params):
    if 'perf_nvidia' not in params:
        return None
    if params['perf_nvidia'] == '0':
        return None
    try:
        delay = int(params['perf_nvidia'])
    except:
        msg = 'setup_perf_nvidia(): params[perf_nvidia] not an int: ' + \
              'got: "%s"' % params['perf_nvidia']
        print(msg)
        raise Exception(msg)
    import subprocess
    with open('perf-nvidia.log', 'a') as fp_out:
        fp_out.write('model_runner: start: %s\n\n' % timestamp())
        P = subprocess.Popen(['nvidia-smi', '--loop='+params['perf_top']],
                             stdout=fp_out,
                             stderr=subprocess.STDOUT)
    return P


def stop_perf(Ps):
    for s in ['top', 'nvidia']:
        if Ps[s] is not None:
            Ps[s].terminate()


def run(hyper_parameter_map, obj_return):
    start = time.time()
    global logger
    logger = log_tools.get_logger(logger, 'MODEL RUNNER')

    log("START:")
    sys.stdout.flush()

    directory = hyper_parameter_map['instance_directory']
    os.chdir(directory)

    with open(directory + '/rank.txt', 'w') as fp:
        fp.write(str(os.getenv('ADLB_RANK_SELF')) + '\n')

    framework = hyper_parameter_map['framework']
    model_name = hyper_parameter_map['model_name']
    pkg = import_pkg(framework, model_name)

    runner_utils.format_params(hyper_parameter_map)

    params_arg = {}
    if 'config_file' in hyper_parameter_map:
        config_file = hyper_parameter_map['config_file']
        logger.info('specified config_file: "%s"' % config_file)
        params_arg = { 'default_model': config_file }

    # params is a python dictionary
    params = setup_params(pkg, hyper_parameter_map, params_arg)

    Ps = setup_perf(params)

    # Run the model!
    history = pkg.run(params)

    if framework == 'keras':
        runner_utils.keras_clear_session(framework)

    # Default result if there is no val_loss (as in infer.py)
    result = 0
    history_result = {}
    if history != None:
        result, history_result = get_results(history, obj_return)

    stop_perf(Ps)

    finish = time.time()
    duration = finish - start
    log(" DONE: run_id %s in %0.2f seconds." %
        (hyper_parameter_map["run_id"], duration))
    return (result, history_result)


def get_obj_return():
    obj_return = os.getenv("OBJ_RETURN")
    valid_obj_returns = [ "loss", "val_loss", "val_corr", "val_acc" ]
    if obj_return == None:
        raise Exception("No OBJ_RETURN was in the environment!")
    if obj_return not in valid_obj_returns:
        raise Exception("Invalid value for OBJ_RETURN: use: " +
                        str(valid_obj_returns))
    return obj_return

def load_pre_post(hyper_parameter_map, key):
    module = None
    if key in hyper_parameter_map:
        module_name = hyper_parameter_map[key]
        module = importlib.import_module(module_name)
    return module

def run_pre(hyper_parameter_map):
    module = load_pre_post(hyper_parameter_map, 'pre_module')
    result = ModelResult.SUCCESS
    if module != None:
        logger.debug("PRE RUN START")
        result = module.pre_run(hyper_parameter_map)
        logger.debug("PRE RUN STOP")
    return result

def run_post(hyper_parameter_map, output_map):
    module = load_pre_post(hyper_parameter_map, 'post_module')
    if module != None:
        logger.debug("POST RUN START")
        module.post_run(hyper_parameter_map, output_map)
        logger.debug("POST RUN STOP")

def run_model(hyper_parameter_map):
    instance_directory = hyper_parameter_map['instance_directory']
    os.chdir(instance_directory)
    global logger
    logger = log_tools.get_logger(logger, "MODEL RUNNER")
    obj_return = get_obj_return()
    result = run_pre(hyper_parameter_map)
    if result == ModelResult.ERROR:
        print("run_pre() returned ERROR!")
        exit(1)
    elif result == ModelResult.SKIP:
        log("run_pre() returned SKIP ...")
        sys.stdout.flush()
        return ("SKIP", "HISTORY_EMPTY")
    else:
        assert(result == ModelResult.SUCCESS) # proceed...

    result, history = run(hyper_parameter_map, obj_return)
    runner_utils.write_output(result, instance_directory)
    runner_utils.write_output(json.dumps(history, cls=runner_utils.FromNPEncoder),
                              instance_directory, 'history.txt')

    run_post(hyper_parameter_map, {})
    log("RUN STOP")
    return (result, history)

def setup_params(pkg, hyper_parameter_map, params_arg):
    params = pkg.initialize_parameters(**params_arg)
    log("PARAM UPDATE START")
    for k,v in hyper_parameter_map.items():
        if k == "dense" or k == "dense_feature_layers":
            if(type(v) != list):
                v = v.split(" ")
            v = [int(i) for i in v]
        if k == "cell_features":
            cp_str = v
            v = list()
            v.append(cp_str)
        log(str(k) + " = " + str(v))
        params[k] = v
    log("PARAM UPDATE STOP")

    log("WRITE_PARAMS START")
    runner_utils.write_params(params, hyper_parameter_map)
    log("WRITE_PARAMS STOP")
    return params


def get_results(history, obj_return):
    """
    Return the history entry that the user requested.
    history: The Keras history object
    """
    values = history.history[obj_return]
    # Default: the last value in the history
    result = values[-1]

    known_params = [ "loss", "val_loss", "val_corr", "val_dice_coef" ]
    if obj_return not in known_params:
        raise ValueError("Unsupported objective function: " +
                         "use obj_param to specify one of " +
                         str(known_params))

    # Fix NaNs:
    if math.isnan(result):
        if obj_return == "val_corr" or obj_return == "val_dice_coef":
            # Return the negative result
            result = -result
        else:
            # Just return a large number
            result = 999999999

    print("result: " + obj_return + ": " + str(result))
    history_result = history.history.copy()
    return result, history_result

# Usage: see how sys.argv is unpacked below:
if __name__ == '__main__':
    logger = log_tools.get_logger(logger, "MODEL_RUNNER")
    log("RUN START")

    ( _, # The Python program name (unused)
      param_string,
      instance_directory,
      framework,
      runid,
      benchmark_timeout ) = sys.argv

    hyper_parameter_map = runner_utils.init(param_string,
                                            instance_directory,
                                            framework,
                                            out_dir_key='save')
    hyper_parameter_map['model_name']    = os.getenv("MODEL_NAME")
    if hyper_parameter_map['model_name'] == None:
        raise Exception("No MODEL_NAME was in the environment!")
    hyper_parameter_map['experiment_id'] = os.getenv("EXPID")
    hyper_parameter_map['run_id']  = runid
    hyper_parameter_map['timeout'] = float(benchmark_timeout)

    # tensorflow.__init__ calls _os.path.basename(_sys.argv[0])
    # so we need to create a synthetic argv.
    # if (not hasattr(sys, 'argv')) or (len(sys.argv) == 0):
    # sys.argv  = ['nt3_tc1']
    sys.argv = ['null']
    run_model(hyper_parameter_map)
