import numpy as np
import json, os

DATA_TYPES = {type(np.float16): 'f16', type(np.float32): 'f32', type(np.float64): 'f64'}

def write_output(result, instance_directory):
    with open('{}/result.txt'.format(instance_directory), 'w') as f_out:
        f_out.write("{}\n".format(result))

def init(param_file, instance_directory, framework, out_dir_key):
    with open(param_file) as f_in:
        hyper_parameter_map = json.load(f_in)

    if not os.path.exists(instance_directory):
        os.makedirs(instance_directory)

    hyper_parameter_map['framework'] = framework
    hyper_parameter_map[out_dir_key] = '{}/output'.format(instance_directory)
    hyper_parameter_map['instance_directory'] = instance_directory

    return hyper_parameter_map

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
