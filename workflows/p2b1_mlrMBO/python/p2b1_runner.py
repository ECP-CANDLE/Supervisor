# tensoflow.__init__ calls _os.path.basename(_sys.argv[0])
# so we need to create a synthetic argv.
import sys
if not hasattr(sys, 'argv'):
    sys.argv  = ['p2b1']

import json
import os
import p2b1
import runner_utils

def run(hyper_parameter_map):
    framework = hyper_parameter_map['framework']
    if framework == 'keras':
        import p2b1_baseline_keras2
        pkg = p2b1_baseline_keras2
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
    loss_history = pkg.run(params)

    if framework == 'keras':
        # works around this error:
        # https://github.com/tensorflow/tensorflow/issues/3388
        try:
            from keras import backend as K
            K.clear_session()
        except AttributeError:      # theano does not have this function
            pass

    return loss_history[-1]

if __name__ == '__main__':
    param_string = sys.argv[1]
    instance_directory = sys.argv[2]
    framework = sys.argv[3]
    exp_id = sys.argv[4]
    run_id = sys.argv[5]
    hyper_parameter_map = runner_utils.init(param_string, instance_directory,
                                            framework, 'save_path')
    hyper_parameter_map['experiment_id'] = exp_id
    hyper_parameter_map['run_id'] = run_id
    # clear sys.argv so that argparse doesn't object
    sys.argv = ['p2b1_runner']
    result = run(hyper_parameter_map)
    runner_utils.write_output(result, instance_directory)
