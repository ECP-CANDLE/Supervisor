# tensoflow.__init__ calls _os.path.basename(_sys.argv[0])
# so we need to create a synthetic argv.
import sys
if not hasattr(sys, 'argv'):
    sys.argv  = ['p1b3']

import json
import os
import p1b3
import runner_utils

def run(hyper_parameter_map):
    framework = hyper_parameter_map['framework']
    if framework == 'keras':
        import p1b3_baseline_keras2
        pkg = p1b3_baseline_keras2
    elif framework == 'mxnet':
        import p1b3_baseline_mxnet
        pkg = p1b3_baseline_mxnet
    elif framework == 'neon':
        import p1b3_baseline_neon
        pkg = p1b3_baseline_neon
    else:
        raise ValueError("Invalid framework: {}".format(framework))

    # params is python dictionary
    params = pkg.initialize_parameters()
    runner_utils.format_params(hyper_parameter_map)

    for k,v in hyper_parameter_map.items():
        #if not k in params:
        #    raise Exception("Parameter '{}' not found in set of valid arguments".format(k))
        params[k] = v

    runner_utils.write_params(params, hyper_parameter_map)
    history = pkg.run(params)

    if framework == 'keras':
        # works around this error:
        # https://github.com/tensorflow/tensorflow/issues/3388
        try:
            from keras import backend as K
            K.clear_session()
        except AttributeError:      # theano does not have this function
            pass

    # use the last validation_loss as the value to minimize
    val_loss = history.history['val_loss']
    return val_loss[-1]

if __name__ == '__main__':
    param_file = sys.argv[1]
    instance_directory = sys.argv[2]
    framework = sys.argv[3]
    hyper_parameter_map = runner_utils.init(param_file, instance_directory, framework,
                               'save')
    # clear sys.argv so that argparse doesn't object
    sys.argv = ['p1b3_runner']
    result = run(hyper_parameter_map)
    runner_utils.write_output(result, instance_directory)
