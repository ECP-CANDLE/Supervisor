# tensoflow.__init__ calls _os.path.basename(_sys.argv[0])
# so we need to create a synthetic argv.
import sys
if not hasattr(sys, 'argv'):
    sys.argv  = ['p3b1']

import json
import os
import p3b1
import runner_utils
import socket

node_pid = "%s,%i" % (socket.gethostname(), os.getpid())
print("node,pid: " + node_pid)

logger = None

def get_logger():
    """ Set up logging """
    global logger
    if logger is not None:
        return logger
    import logging, sys
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)
    h = logging.StreamHandler(stream=sys.stdout)
    fmtr = logging.Formatter('%(asctime)s %(name)s %(levelname)-9s %(message)s',
                             datefmt='%Y/%m/%d %H:%M:%S')
    h.setFormatter(fmtr)
    logger.addHandler(h)
    return logger

def run(hyper_parameter_map):

    logger = get_logger()
    framework = hyper_parameter_map['framework']
    logger.debug("IMPORT START")
    if framework == 'keras':
        import p3b1_baseline_keras2
        pkg = p3b1_baseline_keras2
    else:
        raise ValueError("Unsupported framework: {}".format(framework))
    logger.debug("IMPORT STOP")

    # params is python dictionary
    params = pkg.initialize_parameters()
    runner_utils.format_params(hyper_parameter_map)

    for k,v in hyper_parameter_map.items():
        #if not k in params:
        #    raise Exception("Parameter '{}' not found in set of valid arguments".format(k))
        params[k] = v

    logger.debug("WRITE_PARAMS START")
    runner_utils.write_params(params, hyper_parameter_map)
    logger.debug("WRITE_PARAMS STOP")
    logger.debug("DO_N_FOLD START")
    avg_loss = pkg.do_n_fold(params)
    logger.debug("DO_N_FOLD STOP")

    if framework == 'keras':
        # works around this error:
        # https://github.com/tensorflow/tensorflow/issues/3388
        try:
            from keras import backend as K
            K.clear_session()
        except AttributeError:      # theano does not have this function
            pass

    return avg_loss

if __name__ == '__main__':
    logger = get_logger()
    logger.debug("RUN START")

    param_string = sys.argv[1]
    instance_directory = sys.argv[2]
    framework = sys.argv[3]
    exp_id = sys.argv[4]
    run_id = sys.argv[5]
    benchmark_timeout = int(sys.argv[6])

    logger.debug("RUN INIT START")
    
    hyper_parameter_map = runner_utils.init(param_string, instance_directory,
                                            framework, 'save_path')
    logger.debug("RUN INIT STOP")
    hyper_parameter_map['experiment_id'] = exp_id
    hyper_parameter_map['run_id'] = run_id
    hyper_parameter_map['timeout'] = benchmark_timeout
    # clear sys.argv so that argparse doesn't object
    sys.argv = ['p3b1_runner']
    result = run(hyper_parameter_map)
    logger.debug("WRITE OUTPUT START")
    runner_utils.write_output(result, instance_directory)
    logger.debug("WRITE OUTPUT STOP")
    logger.debug("RUN STOP")
