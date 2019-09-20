# tensoflow.__init__ calls _os.path.basename(_sys.argv[0])
# so we need to create a synthetic argv.
import sys
if not hasattr(sys, 'argv'):
    sys.argv  = ['p3b3']

import json
import os
import numpy as np
import importlib
import runner_utils
import log_tools

logger = None

def import_pkg(framework, model_name):
    if framework == 'keras':
        module_name = "{}_baseline_keras2".format(model_name)
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
    else:
        raise ValueError("Invalid framework: {}".format(framework))
    return pkg

def run(hyper_parameter_map, callbacks):

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
        params[k] = v

    runner_utils.write_params(params, hyper_parameter_map)
    history = pkg.run(params, callbacks)

    runner_utils.keras_clear_session(framework)

    # use the last validation_loss as the value to minimize
    val_loss = history.history['val_loss']
    result = val_loss[-1]
    print("result: ", result)
    return result

if __name__ == '__main__':
    logger = log_tools.get_logger(logger, __name__)
    logger.debug("RUN START")

    param_string = sys.argv[1]
    instance_directory = sys.argv[2]
    model_name = sys.argv[3]
    framework = sys.argv[4]
    exp_id = sys.argv[5]
    run_id = sys.argv[6]
    benchmark_timeout = int(sys.argv[7])
    hyper_parameter_map = runner_utils.init(param_string, instance_directory, framework, 'save')
    hyper_parameter_map['model_name'] = model_name
    hyper_parameter_map['experiment_id'] = exp_id
    hyper_parameter_map['run_id'] = run_id
    hyper_parameter_map['timeout'] = benchmark_timeout
    # clear sys.argv so that argparse doesn't object
    sys.argv = ['p3b3_runner']
    result = run(hyper_parameter_map)
    runner_utils.write_output(result, instance_directory)
    logger.debug("RUN STOP")
