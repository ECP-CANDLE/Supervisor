# tensoflow.__init__ calls _os.path.basename(_sys.argv[0])
# so we need to create a synthetic argv.
import sys
if not hasattr(sys, 'argv'):
    sys.argv  = ['p1b3']

import json

import os
import p1b3_baseline_keras2
import p1b3

def run(hyper_parameter_map):
    parser = p1b3_baseline_keras2.get_parser()
    # args is a argparse.Namespace
    args = parser.parse_args()
    for k,v in hyper_parameter_map.items():
        if not hasattr(args, k):
            raise Exception("Parameter '%s' not found in set of valid arguments" % k)
        setattr(args, k, v)

    history = p1b3_baseline_keras2.run(args)

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
