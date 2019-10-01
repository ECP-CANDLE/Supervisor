
# MODEL RUNNER PY

# See __main__ section for usage

import sys
import json
import os
import numpy as np
import importlib
import runner_utils
from runner_utils import ModelResult
import log_tools
import math

logger = None

print("MODEL RUNNER...")

# Andrew: Adding the following line (switching the order of the following two lines) in order to append an arbitrary model's dependencies to the path *before* the benchmarks in order to accidentally use a benchmark dependency
sys.path.append(os.getenv("MODEL_PYTHON_DIR"))
sys.path.append(os.getenv("BENCHMARKS_ROOT")+"/common")

import candle_lrn_crv

print("sys.path:")
for i in range(0, len(sys.path)-1):
    print("%2i: %s" % (i, sys.path[i]))
print("")

def import_pkg(framework, model_name):
    # The model_name is the short form of the Benchmark: e.g., 'nt3'
    # The module_name is the name of the Python module:  e.g., 'nt3_baseline_keras2'
    print("model_name: ", model_name)
    if framework != 'keras':
        raise ValueError("Invalid framework: '{}'".format(framework))
    module_name = os.getenv("MODEL_PYTHON_SCRIPT")
    if module_name == None or module_name == "":
        module_name = "{}_baseline_keras2".format(model_name)
    print ("module_name:", module_name)
    pkg = importlib.import_module(module_name)

    from keras import backend as K
    if K.backend() == 'tensorflow' and 'NUM_INTER_THREADS' in os.environ:
        import tensorflow as tf
        inter_threads = int(os.environ['NUM_INTER_THREADS'])
        intra_threads = int(os.environ['NUM_INTRA_THREADS'])
        print("Configuring tensorflow with {} inter threads and {} intra threads"
              .format(inter_threads, intra_threads))
        cfg = tf.ConfigProto(inter_op_parallelism_threads=inter_threads,
                             intra_op_parallelism_threads=intra_threads)
        sess = tf.Session(graph=tf.get_default_graph(), config=cfg)
        K.set_session(sess)
    return pkg

def log(msg):
    global logger
    logger.debug("model_runner: " + msg)

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
        msg = 'setup_perf_nvidia(): params[perf_nvidia] not an int: got: "%s"' % \
              params['perf_nvidia']
        print(msg)
        raise Exception(msg)
    import subprocess
    with open('perf-nvidia.log', 'a') as fp_out:
        fp_out.write('model_runner: start: %s\n\n' % timestamp())
        P = subprocess.Popen(['nvidia-smi', '--loop='+params['perf_top']],
                             stdout=fp_out,
                             stderr=subprocess.STDOUT)
    return P

def run(hyper_parameter_map, obj_return):

    global logger
    logger = log_tools.get_logger(logger, "MODEL RUNNER")

    framework = hyper_parameter_map['framework']
    model_name = hyper_parameter_map['model_name']
    # pkg = import_pkg(framework, model_name)

    runner_utils.format_params(hyper_parameter_map)

    # params is python dictionary
    # params = pkg.initialize_parameters()
    params = nn_reg0.initialize_parameters()
    for k,v in hyper_parameter_map.items():
        #if not k in params:
        #    raise Exception("Parameter '{}' not found in set of valid arguments".format(k))
        if(k=="dense"):
            if(type(v) != list):
                v=v.split(" ")
            v = [int(i) for i in v]
        if(k=="dense_feature_layers"):
            if(type(v) != list):
                v=v.split(" ")
            v = [int(i) for i in v]
        if(k=="cell_features"):
            cp_str = v
            v = list()
            v.append(cp_str)
        log("PARAM OVERWRITE: " + str(k) + " = " + str(v))
        params[k] = v

    log("WRITE_PARAMS START")
    runner_utils.write_params(params, hyper_parameter_map)
    log("WRITE_PARAMS STOP")

    Ps = setup_perf(params)

    # Run the model!
    # history = pkg.run(params)
    history = nn_reg0.run(params)

    runner_utils.keras_clear_session(framework)

    # Default result if there is no val_loss (as in infer.py)
    result = 0
    if history != None:
        # Return the history entry that the user requested.
        values = history.history[obj_return]
        # Return a large number for nan and flip sign for val_corr
        if(obj_return == "val_loss"):
            if(math.isnan(values[-1])):
                result = 999999999
            else:
                result = values[-1]
        elif(obj_return == "val_corr" or obj_return == "val_dice_coef"): # allow for the return variable to be the val_dice_coef, which is sometimes used by arbitrary models instead of val_corr
            if(math.isnan(val_loss[-1])):
                result = 999999999
            else:
                result = -values[-1] # Note negative sign
        else:
            raise ValueError("Unsupported objective function " +
                             "(use obj_param to specify val_corr or val_loss): " +
                             framework)

        print("result: " + obj_return + ": " + str(result))

    for s in ['top', 'nvidia']:
        if Ps[s] is not None:
            Ps[s].terminate()
    return result

def get_obj_return():
    obj_return = os.getenv("OBJ_RETURN")
    valid_obj_returns = [ "val_loss", "val_corr" ]
    if obj_return == None:
        raise Exception("No OBJ_RETURN was in the environment!")
    if obj_return not in valid_obj_returns:
        raise Exception("Invalid value for OBJ_RETURN: use: " +
                        valid_obj_returns)
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

def run_post(hyper_parameter_map):
    module = load_pre_post(hyper_parameter_map, 'post_module')
    if module != None:
        logger.debug("POST RUN START")
        module.post_run(hyper_parameter_map)
        logger.debug("POST RUN STOP")


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

    obj_return = get_obj_return()

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

    result = run_pre(hyper_parameter_map)
    if result == ModelResult.ERROR:
        print("run_pre() returned ERROR!")
        exit(1)
    elif result == ModelResult.SKIP:
        print("run_pre() returned SKIP ...")
        exit(0)
    else:
        assert(result == ModelResult.SUCCESS) # proceed...

    # Call to Benchmark!
    log("CALL BENCHMARK " + hyper_parameter_map['model_name'])
    print("sys.argv=" + str(sys.argv))
    result = run(hyper_parameter_map, obj_return)
    runner_utils.write_output(result, instance_directory)
    run_post(hyper_parameter_map)

    log("RUN STOP")
