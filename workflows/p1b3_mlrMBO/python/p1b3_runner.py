# tensoflow.__init__ calls _os.path.basename(_sys.argv[0])
# so we need to create a synthetic argv.
import sys
if not hasattr(sys, 'argv'):
    sys.argv  = ['p1b3']

import json
import os
import p1b3
import numpy as np

DATA_TYPES = {type(np.float16): 'f16', type(np.float32): 'f32', type(np.float64): 'f64'}

def write_params(params, hyper_parameter_map):
    parent_dir =  hyper_parameter_map['instance_directory'] if 'instance_directory' in hyper_parameter_map else '.'
    f = "{}/parameters.txt".format(parent_dir)
    with open(f, "w") as f_out:
        f_out.write("[parameters]\n")
        for k,v in params.items():
            if type(v) in DATA_TYPES:
                v = DATA_TYPES[type(v)]
            if isinstance(v, basestring):
                v = "'{}'".format(v)
            f_out.write("{}={}\n".format(k, v))

def is_numeric(val):
    try:
        float(val)
        return True
    except ValueError:
        return False

def format_params(hyper_parameter_map):
    for k,v in hyper_parameter_map.items():
        vals = str(v).split(" ")
        if len(vals) > 1 and is_numeric(vals[0]):
            # assume this should be a list
            if "." in vals[0]:
                hyper_parameter_map[k] = [float(x) for x in vals]
            else:
                hyper_parameter_map[k] = [int(x) for x in vals]

def run(hyper_parameter_map):
    framework = hyper_parameter_map['framework']
    if framework is 'keras':
        import p1b3_baseline_keras2
        pkg = p1b3_baseline_keras2
    elif framework is 'mxnet':
        import p1b3_baseline_mxnet
        pkg = p1b3_baseline_mxnet
    elif framework is 'neon':
        import p1b3_baseline_neon
        pkg = p1b3_baseline_neon
    else:
        raise ValueError("Invalid framework: {}".format(framework))

    # params is python dictionary
    params = pkg.initialize_parameters()
    format_params(hyper_parameter_map)

    for k,v in hyper_parameter_map.items():
        #if not k in params:
        #    raise Exception("Parameter '{}' not found in set of valid arguments".format(k))
        params[k] = v

    write_params(params, hyper_parameter_map)
    history = pkg.run(params)

    if framework is 'keras':
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

def write_output(result, instance_directory):
    with open('{}/result.txt'.format(instance_directory), 'w') as f_out:
        f_out.write("{}\n".format(result))

def init(param_file, instance_directory):
    with open(param_file) as f_in:
        hyper_parameter_map = json.load(f_in)

    hyper_parameter_map['framework'] = 'keras'
    hyper_parameter_map['save'] = '{}/output'.format(instance_directory)
    hyper_parameter_map['instance_directory'] = instance_directory
    
    return hyper_parameter_map

if __name__ == '__main__':
    param_file = sys.argv[1]
    instance_directory = sys.argv[2]
    hyper_parameter_map = init(param_file, instance_directory)
    # clear sys.argv so that argparse doesn't object
    sys.argv = ['p1b3_runner']
    result = run(hyper_parameter_map)
    write_output(result, instance_directory)
