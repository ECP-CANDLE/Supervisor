
# MODEL RUNNER PY

# Currently only supports NT3_TC1 # Not true? -Justin 2018/02/28
# See __main__ section for usage

import sys
import json
import os
import numpy as np
import importlib
import runner_utils
import log_tools
import math
logger = None

print("MODEL RUNNER...")

sys.path.append(os.getenv("BENCHMARKS_ROOT")+"/common")
sys.path.append(os.getenv("MODEL_PYTHON_DIR"))

print("sys.path:")
print(sys.path)
print("")

def import_pkg(framework, model_name):
    print ("model_name", model_name)
    if framework == 'keras':
        module_name = os.getenv("MODEL_PYTHON_SCRIPT") if "MODEL_PYTHON_SCRIPT" in os.environ and os.getenv("MODEL_PYTHON_SCRIPT") != "" else "{}_baseline_keras2".format(model_name)
        print ("module_name:", module_name)
        pkg = importlib.import_module(module_name)

        from keras import backend as K
        if K.backend() == 'tensorflow' and 'NUM_INTER_THREADS' in os.environ:
            import tensorflow as tf
            print("Configuring tensorflow with {} inter threads and {} intra threads".
                format(os.environ['NUM_INTER_THREADS'], os.environ['NUM_INTRA_THREADS']))
            session_conf = tf.ConfigProto(inter_op_parallelism_threads=int(os.environ['NUM_INTER_THREADS']),
                intra_op_parallelism_threads=int(os.environ['NUM_INTRA_THREADS']))
            sess = tf.Session(graph=tf.get_default_graph(), config=session_conf)
            K.set_session(sess)
    # elif framework is 'mxnet':
    #     import nt3_baseline_mxnet
    #     pkg = nt3_baseline_keras_baseline_mxnet
    # elif framework is 'neon':
    #     import nt3_baseline_neon
    #     pkg = nt3_baseline_neon
    else:
        raise ValueError("Invalid framework: {}".format(framework))
    return pkg

def run(hyper_parameter_map, obj_return):

    global logger
    logger = log_tools.get_logger(logger, __name__)

    framework = hyper_parameter_map['framework']
    model_name = hyper_parameter_map['model_name']
    pkg = import_pkg(framework, model_name)

    runner_utils.format_params(hyper_parameter_map)

    # params is python dictionary
    params = pkg.initialize_parameters()
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
        params[k] = v

    logger.debug("WRITE_PARAMS START")
    runner_utils.write_params(params, hyper_parameter_map)
    logger.debug("WRITE_PARAMS STOP")

    history = pkg.run(params)

    runner_utils.keras_clear_session(framework)

    # Default result if there is no val_loss (as in infer.py)
    result = 0
    if history != None:
        # Return the history entry that the user requested.
        val_loss = history.history[obj_return]
        # Return a large number for nan and flip sign for val_corr
        if(obj_return == "val_loss"):
            if(math.isnan(val_loss[-1])):
                result = 999999999
            else:
                result = val_loss[-1]
        elif(obj_return == "val_corr"):
            if(math.isnan(val_loss[-1])):
                result = 999999999
            else:
                result = -val_loss[-1] #Note negative sign
        else:
            raise ValueError("Unsupported objective function (use obj_param to specify val_corr or val_loss): {}".format(framework))

        print("result: " + str(result))
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

# Usage: see how sys.argv is unpacked below:
if __name__ == '__main__':
    logger = log_tools.get_logger(logger, __name__)
    logger.debug("RUN START")

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
    # sys.argv = ['p1b1']

    # Call to Benchmark!
    logger.debug("CALL BENCHMARK " + hyper_parameter_map['model_name'])
    # print("sys.argv=" + str(sys.argv))
    result = run(hyper_parameter_map, obj_return)

    runner_utils.write_output(result, instance_directory)
    logger.debug("RUN STOP")
