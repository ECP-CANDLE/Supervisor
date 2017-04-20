# tensoflow.__init__ calls _os.path.basename(_sys.argv[0])
# so we need to create a synthetic argv.
import sys
if not hasattr(sys, 'argv'):
    sys.argv  = ['p1b1']

import os
import p1b1_baseline
import p1b1

X_train = None
X_test = None

def run(data_directory, parameter_string):
    global X_train, X_test
    # params are a comma separated list where the order of the
    # params is the param.set order. For example:
    # param.set <- makeParamSet(
    #  makeIntegerParam('epoch', lower = 2, upper = 5),
    #  makeIntegerParam('batch size', lower = 50, upper = 100)
    # )
    # yields strings like 4, 62 where epoch is 4 and batch size is 62

    if X_train is None:
        print("loading data")
        test_path = '{}/P1B1.test.csv'.format(data_directory)
        train_path = '{}/P1B1.train.csv'.format(data_directory)
        if not os.path.exists(test_path):
            raise IOError("Invalid test data path: '{}'".format(test_path))
        if not os.path.exists(train_path):
            raise IOError("Invalid training data path: '{}'".format(train_path))

        X_train, X_test = p1b1.load_data(test_path=test_path, train_path=train_path)

    params = parameter_string.split(',')

    # this assumes a simple space. A more complicated space
    # will require additional unpacking.

    epochs = int(params[0].strip())
    encoder, decoder, history = p1b1_baseline.run_p1b1(X_train, X_test, epochs=epochs)

    # works around this error:
    # https://github.com/tensorflow/tensorflow/issues/3388
    from keras import backend as K
    K.clear_session()

    # use the last validation_loss as the value to minimize
    val_loss = history.history['val_loss']
    return val_loss[-1]
